#!/bin/bash
# CopilotKit RDS Database Setup Script
# Run this script to initialize your RDS PostgreSQL instance with CopilotKit tables

set -e

# Load environment variables
if [ -f .env ]; then
    source .env
fi

# Extract database connection details from DATABASE_URL
# Format: postgresql://username:password@host:port/database
DB_URL=${DATABASE_URL:-"postgresql://username:password@your-rds-endpoint:5432/copilotkit"}

echo "🚀 Setting up CopilotKit database schema on RDS..."

# Use psql to execute the initialization script
psql "$DB_URL" -f init-db.sql

echo "✅ Database schema created successfully!"
echo ""
echo "📋 Created tables:"
echo "  - sessions (for user session management)"
echo "  - conversations (for chat history)"
echo "  - actions (for copilot action tracking)"
echo "  - users (for user management)"
echo ""
echo "🎯 Your RDS database is now ready for CopilotKit!"