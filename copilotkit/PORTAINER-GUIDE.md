# CopilotKit for Portainer Deployment

This Docker Compose file is optimized for deployment through Portainer with externalized environment variables.

## 🚀 Quick Deployment in Portainer

### Step 1: Create Stack in Portainer
1. Go to **Stacks** in Portainer
2. Click **Add Stack**
3. Choose **Web editor** or **Upload**
4. Copy the contents of `docker-compose-final.yml`

### Step 2: Configure Environment Variables
In Portainer's **Environment variables** section, add these required variables:

#### Required Variables
```bash
OLLAMA_BASE_URL=https://your-ollama-endpoint.com
DATABASE_URL=postgresql://username:password@your-rds-host:5432/database_name
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
RDS_HOST=your-rds-host.amazonaws.com
```

#### Optional Variables (with sensible defaults)
```bash
NODE_ENV=production
PORT=9229
OLLAMA_MODEL=deepseek-r1:14b
LLM_PROVIDER=ollama
OPENAI_API_KEY=ollama-placeholder
CORS_ORIGIN=*
LOG_LEVEL=info
WS_ENABLED=true
EPHEMERAL_STORAGE=true
REDIS_PASSWORD=copilotkit
RDS_DB_DRIVER=pgsql
```

### Step 3: Deploy
1. Click **Deploy the stack**
2. Wait for services to start (first startup takes 2-3 minutes)
3. Check service health in Portainer or via endpoints

## 📊 Service Endpoints

After deployment, services will be available at:

- **CopilotKit API**: `http://your-server:9229/api/copilotkit`
- **Health Check**: `http://your-server:9229/health`
- **Service Info**: `http://your-server:9229/`
- **Redis**: Port `6380` (internal use)

## 🛠️ Optional Tools

To enable additional management tools, add this to the deploy command in Portainer:
```bash
--profile tools
```

This will start:
- **Adminer** (Database UI): Port `8081`
- **Redis Commander** (Redis UI): Port `8082`

## 🔐 Security Best Practices

1. **Change Default Passwords**: Update `REDIS_PASSWORD` and `JWT_SECRET`
2. **Restrict CORS**: Set `CORS_ORIGIN` to your specific domain instead of `*`
3. **Use Secrets**: In production, use Docker Secrets or Portainer's secret management
4. **Network Isolation**: Consider using custom networks in Portainer

## 🔍 Troubleshooting

### Check Logs in Portainer
1. Go to **Stacks** → Your Stack
2. Click on the stack name
3. View container logs for `copilotkit-runtime`

### Common Issues
- **Slow startup**: First run takes time installing dependencies
- **Database connection**: Verify `DATABASE_URL` format and credentials
- **Ollama connection**: Ensure `OLLAMA_BASE_URL` is accessible from container

### Health Check Commands
```bash
# From Portainer console or host
curl http://localhost:9229/health
curl http://localhost:9229/
```

## 🔄 Updates

To update CopilotKit:
1. In Portainer, go to your stack
2. Click **Editor**
3. Re-deploy the stack (dependencies will update automatically)

## 📋 Environment Variable Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OLLAMA_BASE_URL` | ✅ | - | Your Ollama API endpoint |
| `DATABASE_URL` | ✅ | - | PostgreSQL connection string |
| `JWT_SECRET` | ✅ | - | JWT signing secret |
| `RDS_HOST` | ✅ | - | Database host for Adminer |
| `NODE_ENV` | ❌ | production | Node.js environment |
| `PORT` | ❌ | 9229 | CopilotKit service port |
| `OLLAMA_MODEL` | ❌ | deepseek-r1:14b | Ollama model to use |
| `CORS_ORIGIN` | ❌ | * | Allowed CORS origins |
| `REDIS_PASSWORD` | ❌ | copilotkit | Redis password |

## 🎯 Production Deployment

For production use in Portainer:
1. Use Docker Secrets for sensitive values
2. Set up proper networking and reverse proxy
3. Configure log drivers for centralized logging
4. Set resource limits in the compose file
5. Use specific image tags instead of `latest`