# Firecrawl Self-Hosted Stack

This Compose bundle launches the Firecrawl API, BullMQ workers, Playwright microservice, and Redis cache. Pair it with an external Postgres instance (e.g. AWS RDS) for NuQ job storage.

## Prerequisites

- Docker Engine 24+ and Docker Compose v2
- At least 4 CPU cores / 8 GB RAM recommended for moderate crawl volumes
- An accessible PostgreSQL 13+ instance with the `pg_cron` extension enabled
- Access to any external LLM/search providers you plan to integrate (OpenAI, Ollama, Serper, etc.)

## 1. Configure Environment Variables

1. Duplicate the template:
   ```bash
   cp .env.example .env
   ```
2. Edit `.env` with your secrets and overrides:
   - Replace the sample `NUQ_DATABASE_URL` with your RDS/Postgres connection string (ensure `pg_cron` is enabled and the NuQ schema seeded).
   - Change `BULL_AUTH_KEY` if the admin UI is exposed.
   - Point `OLLAMA_BASE_URL`, `OPENAI_API_KEY`, or other providers to services you control.
   - Set `USE_DB_AUTHENTICATION=true` **only** if you have Supabase credentials; otherwise leave it `false`.

## 2. Prepare AWS RDS (first-time setup)

Run the helper script to validate the instance, create the Firecrawl database, and seed the NuQ schema:

```bash
./scripts/setup_rds.sh \
  BASE_DATABASE_URL="postgresql://<user>:<password>@<endpoint>:5432"
```

Export `FIRECRAWL_DB_NAME` or `FIRECRAWL_DATABASE_URL` if you need custom names. The script requires `psql` and assumes `pg_cron` is preloaded via the DB parameter group.

## 3. Start the Stack

```bash
docker compose --env-file .env up -d
```

Useful commands:
- Follow logs: `docker compose logs -f api queue-worker nuq-worker`
- Check health: `curl http://localhost:${FIRECRAWL_HTTP_PORT:-3002}/v0/health/liveness`

## 4. Scale Out Workers (optional)

Increase crawl throughput vertically:
```bash
docker compose --env-file .env up -d --scale nuq-worker=5
```
Adjust `NUM_WORKERS_PER_QUEUE` if you hit CPU limits inside the queue worker container.

## 5. Shutdown and Maintenance

- Stop services: `docker compose --env-file .env down`
- Remove persistent data (Redis): `docker compose --env-file .env down -v`
- Update images: `docker compose --env-file .env pull && docker compose --env-file .env up -d`

Redis state lives in the `redis-data` Docker volume. Back it up if you need to preserve queue metrics or rate-limit data. Postgres data resides in RDS.

## Notes

- Supabase is optional and only required when enabling database-backed authentication features.
- Ensure outbound requests (LLM providers, web crawling) are allowed from the host network.
- For production, front the `api` service with a reverse proxy (e.g., Traefik, Nginx) and lock down the BullMQ admin UI (`/admin/${BULL_AUTH_KEY}/queues`).

Happy crawling! 🚀
