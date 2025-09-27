FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget

# Initialize npm and install dependencies
RUN npm init -y && \
    npm install --no-audit --no-fund @copilotkit/runtime@latest express cors dotenv

# Create server.js
COPY <<EOF server.js
const express = require('express');
const cors = require('cors');
const { CopilotRuntime, OpenAIAdapter } = require('@copilotkit/runtime');

const app = express();
const port = process.env.PORT || 9229;

console.log('🔧 Initializing CopilotKit Runtime...');
console.log('📡 Ollama endpoint:', process.env.OLLAMA_BASE_URL);
console.log('🧠 Using model:', process.env.OLLAMA_MODEL);

// Middleware
app.use(cors({ 
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    service: 'CopilotKit Runtime',
    ollama_endpoint: process.env.OLLAMA_BASE_URL,
    model: process.env.OLLAMA_MODEL
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'CopilotKit Runtime',
    status: 'running',
    endpoints: {
      health: '/health',
      copilotkit: '/api/copilotkit'
    }
  });
});

// Configure the OpenAI adapter for Ollama with proper API key handling
const serviceAdapter = new OpenAIAdapter({
  model: process.env.OLLAMA_MODEL || 'deepseek-r1:14b',
  baseURL: process.env.OLLAMA_BASE_URL,
  apiKey: 'ollama', // Ollama doesn't need a real API key, just a placeholder
});

// CopilotKit runtime endpoint - Updated API usage
const runtime = new CopilotRuntime();
app.all('/api/copilotkit', async (req, res) => {
  try {
    const response = await runtime.response({
      body: req.body,
      request: req,
      response: res,
      serviceAdapter: serviceAdapter,
    });
    return response;
  } catch (error) {
    console.error('❌ CopilotKit runtime error:', error);
    return res.status(500).json({ 
      error: 'Runtime error', 
      message: error.message 
    });
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error('❌ Error:', err);
  res.status(500).json({ error: 'Internal Server Error', message: err.message });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found', path: req.path });
});

// Start server
const server = app.listen(port, '0.0.0.0', () => {
  console.log('🚀 CopilotKit Runtime listening on port ' + port);
  console.log('📊 Health check: http://localhost:' + port + '/health');
  console.log('🤖 CopilotKit API: http://localhost:' + port + '/api/copilotkit');
  console.log('🎯 Ollama endpoint: ' + process.env.OLLAMA_BASE_URL);
  console.log('🧠 Using model: ' + (process.env.OLLAMA_MODEL || 'deepseek-r1:14b'));
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => process.exit(0));
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => process.exit(0));
});
EOF

# Expose port
EXPOSE 9229

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9229/health || exit 1

# Start the application
CMD ["node", "server.js"]