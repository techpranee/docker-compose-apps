# CopilotKit Docker Compose - Standalone Edition (Portainer Ready)

This is a completely self-contained Docker Compose setup for CopilotKit with externalized environment variables - perfect for Portainer deployments. No Dockerfile or separate config files needed.

## 🚀 Quick Start

### Local Development
```bash
# Create environment file
cp portainer.env .env.local
# Edit .env.local with your values

# Start the services
docker-compose -f docker-compose-final.yml --env-file .env.local up -d
```

### Portainer Deployment
See `PORTAINER-GUIDE.md` for detailed Portainer setup instructions.

```bash
# In Portainer: Copy docker-compose-final.yml content and set environment variables
# Required variables: OLLAMA_BASE_URL, DATABASE_URL, JWT_SECRET, RDS_HOST
```

# Check status
docker-compose -f docker-compose-final.yml ps

# View logs
docker-compose -f docker-compose-final.yml logs copilotkit-runtime

# Stop services
docker-compose -f docker-compose-final.yml down
```

## 📋 What's Included

### Core Services
- **CopilotKit Runtime**: Port `9229` - AI runtime service
- **Redis**: Port `6380` - Caching and session management

### Optional Tools (run with `--profile tools`)
- **Adminer**: Port `8081` - Web UI for RDS database management
- **Redis Commander**: Port `8082` - Web UI for Redis management

```bash
# Start with optional tools
docker-compose -f docker-compose-final.yml --profile tools up -d
```

## 🔧 Configuration

All configuration is now externalized as environment variables for Portainer compatibility:

### Required Environment Variables
- `OLLAMA_BASE_URL`: Your Ollama API endpoint
- `DATABASE_URL`: PostgreSQL connection string
- `JWT_SECRET`: JWT signing secret (generate a secure random string)
- `RDS_HOST`: Database host for Adminer UI

### Optional Variables (with defaults)
- `OLLAMA_MODEL`: Model to use (default: deepseek-r1:14b)
- `PORT`: Service port (default: 9229)
- `REDIS_PASSWORD`: Redis password (default: copilotkit)
- `CORS_ORIGIN`: Allowed origins (default: *)

See `portainer.env` for a complete template.

## 🏗️ Architecture

- **Stateless Design**: Uses hosted RDS, no local database storage
- **Hosted LLM**: Connects to external Ollama API
- **Container Build**: Dynamically installs dependencies on startup
- **Health Checks**: Built-in monitoring for all services

## 📊 Endpoints

- **Health Check**: `http://localhost:9229/health`
- **CopilotKit API**: `http://localhost:9229/api/copilotkit`
- **Service Info**: `http://localhost:9229/`

## ✅ Advantages of Standalone Version

1. **Single File**: Everything in one Docker Compose file
2. **No Dependencies**: No external Dockerfile or .env files needed
3. **Portable**: Easy to share and deploy anywhere
4. **Self-Contained**: All configuration embedded
5. **Latest Dependencies**: Always installs latest versions on startup

## 🔍 Troubleshooting

### Slow First Startup
The first startup takes 2-3 minutes as it downloads and installs all Node.js dependencies.

### Check Logs
```bash
docker-compose -f docker-compose-final.yml logs -f copilotkit-runtime
```

### Service Health
```bash
curl http://localhost:9229/health
```

### Reset Everything
```bash
docker-compose -f docker-compose-final.yml down -v
docker-compose -f docker-compose-final.yml up -d
```

## 🎯 Use Cases

Perfect for:
- Quick demos and testing
- Development environments
- CI/CD pipelines
- Educational purposes
- Sharing with team members

The standalone approach trades some performance (startup time) for maximum portability and simplicity.