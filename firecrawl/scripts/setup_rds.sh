#!/usr/bin/env bash
set -euo pipefail

# This script verifies that a managed Postgres instance (e.g. AWS RDS)
# meets Firecrawl's NuQ requirements, creates the target database if it
# does not exist, and seeds the schema when missing. It requires psql.

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
NUQ_SQL_PATH="${PROJECT_ROOT}/nuq-postgres/nuq.sql"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql command not found. Please install the PostgreSQL client." >&2
  exit 1
fi

DEFAULT_BASE_URL="postgresql://postgres:techpranee@techpranee.csghg5x1e4dy.ap-south-1.rds.amazonaws.com:5432"
BASE_URL="${BASE_DATABASE_URL:-${DEFAULT_BASE_URL}}"
ADMIN_DATABASE_URL="${ADMIN_DATABASE_URL:-${BASE_URL}/postgres}"
FIRECRAWL_DB_NAME="${FIRECRAWL_DB_NAME:-firecrawl}"
FIRECRAWL_DATABASE_URL="${FIRECRAWL_DATABASE_URL:-${BASE_URL}/${FIRECRAWL_DB_NAME}}"

log() {
  printf '[setup_rds] %s\n' "$*"
}

run_psql() {
  local url="$1"; shift
  psql "$url" -v ON_ERROR_STOP=1 "$@"
}

query_single() {
  local url="$1"; shift
  run_psql "$url" -Atqc "$*"
}

if command -v python3 >/dev/null 2>&1; then
  DISPLAY_ENDPOINT=$(python3 - "$ADMIN_DATABASE_URL" <<'PY'
import sys
from urllib.parse import urlparse
parsed = urlparse(sys.argv[1])
port = f":{parsed.port}" if parsed.port else ""
print(f"{parsed.scheme}://{parsed.hostname}{port}{parsed.path and parsed.path != '/' and parsed.path or ''}")
PY
  )
else
  DISPLAY_ENDPOINT="specified database"
fi

log "Checking connectivity to ${DISPLAY_ENDPOINT}"
run_psql "$ADMIN_DATABASE_URL" -c 'SELECT 1;' >/dev/null

server_version=$(query_single "$ADMIN_DATABASE_URL" 'SHOW server_version;')
server_major=${server_version%%.*}
log "Server version: ${server_version}"
if (( server_major < 13 )); then
  echo "Postgres ${server_version} detected. Firecrawl requires Pg 13+ for pg_cron support." >&2
  exit 1
fi

preload_libs=$(query_single "$ADMIN_DATABASE_URL" 'SHOW shared_preload_libraries;')
if [[ "${preload_libs}" != *pg_cron* ]]; then
  echo "pg_cron not found in shared_preload_libraries. Update the DB parameter group to include pg_cron and restart the instance." >&2
  exit 1
fi
log "pg_cron is present in shared_preload_libraries"

exists=$(query_single "$ADMIN_DATABASE_URL" "SELECT 1 FROM pg_database WHERE datname='${FIRECRAWL_DB_NAME}'")
if [[ -z "$exists" ]]; then
  log "Creating database ${FIRECRAWL_DB_NAME}"
  run_psql "$ADMIN_DATABASE_URL" -c "CREATE DATABASE \"${FIRECRAWL_DB_NAME}\";"
else
  log "Database ${FIRECRAWL_DB_NAME} already exists"
fi

log "Ensuring required extensions exist"
run_psql "$FIRECRAWL_DATABASE_URL" -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto;'
if ! run_psql "$FIRECRAWL_DATABASE_URL" -c 'CREATE EXTENSION IF NOT EXISTS pg_cron;' >/dev/null 2>&1; then
  echo "Failed to create pg_cron extension. Verify pg_cron is installed and enabled on the server." >&2
  exit 1
fi

has_queue=$(query_single "$FIRECRAWL_DATABASE_URL" "SELECT 1 FROM information_schema.tables WHERE table_schema='nuq' AND table_name='queue_scrape';")
if [[ -z "$has_queue" ]]; then
  log "Seeding NuQ schema from ${NUQ_SQL_PATH}"
  run_psql "$FIRECRAWL_DATABASE_URL" -f "$NUQ_SQL_PATH"
else
  log "NuQ schema already present; skipping seed"
fi

log "RDS instance is ready for Firecrawl"
