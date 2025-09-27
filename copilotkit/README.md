# CopilotKit Docker Compose Setup (Simplified Single-File Approach)

This directory contains a **simplified stateless** Docker Compose setup for hosting CopilotKit with:
- **Hosted RDS** for database persistence
- **Hosted Ollama** for LLM inference  
- **Redis** for caching and session management (only persistent component)
- **Inline CopilotKit Runtime** built directly in docker-compose.yml (no separate Dockerfile needed)
- **No Nginx** (assumes you're using Nginx Proxy Manager)

## 🎯 **Single File Setup - No Build Required!**

Everything is contained in the `docker-compose.yml` file with inline commands that:
- ✅ Install CopilotKit runtime dependencies automatically
- ✅ Create the Express server code inline
- ✅ Start the service without any external files
- ✅ No Dockerfile or package.json needed

## 🚀 Quick Start

1. **Copy the environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file with your hosted service details:**
   ```bash
   # Required: Add your hosted service endpoints
   DATABASE_URL=postgresql://postgres:techpranee@techpranee.csghg5x1e4dy.ap-south-1.rds.amazonaws.com:5432/copilotkit
   OLLAMA_BASE_URL=https://your-hosted-ollama-endpoint.com
   
   # Configure model and Redis
   OLLAMA_MODEL=deepseek-r1:14b
   REDIS_PASSWORD=your-redis-password
   ```

3. **Initialize your RDS database (one-time setup):**
   ```bash
   chmod +x setup-rds.sh
   ./setup-rds.sh
   ```

4. **Start the services (everything builds automatically):**
   ```bash
   docker-compose up -d
   ```

That's it! No build steps, no separate files, just pure Docker Compose! 🎉

## 📊 Accessing the Services

- **CopilotKit API**: http://localhost:9229
- **Health Check**: http://localhost:9229/health
- **Redis**: localhost:6380
- **RDS Admin** (Adminer): http://localhost:8081 (with `--profile tools`)
- **Redis Admin**: http://localhost:8082 (with `--profile tools`)

## 🛠️ Management Commands

### Start services (automatic inline build)
```bash
docker-compose up -d
```

### View logs (for debugging)
```bash
docker-compose logs -f copilotkit-runtime
```

### Test the runtime
```bash
# Health check
curl http://localhost:9229/health

# Service info  
curl http://localhost:9229/
```

### Start with management tools
```bash
docker-compose --profile tools up -d
```

The inline approach automatically:
1. **Sets up Node.js environment** using `node:18-alpine`
2. **Installs dependencies** via npm (@copilotkit/runtime, express, cors, etc.)
3. **Creates server.js** with inline code
4. **Starts the service** - all in one command!

Perfect for rapid deployment and easy customization! 🚀