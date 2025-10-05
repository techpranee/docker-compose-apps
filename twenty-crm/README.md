# Twenty CRM Docker Compose for Portainer

This directory contains the Docker Compose configuration for deploying Twenty CRM using Portainer.

## Prerequisites

- Portainer installed and running
- Docker environment managed by Portainer
- At least 2GB RAM available
- External PostgreSQL database (RDS)

## Setup Instructions

### 1. Configure Environment Variables

Edit the `.env` file with your specific values:

- **SERVER_URL**: Set to your external URL (e.g., `https://your-domain.com` or `http://your-server-ip:5529`)
- **PG_DATABASE_URL**: Set to your RDS PostgreSQL connection string (e.g., `postgres://username:password@rds-host:5432/database_name`)
- **APP_SECRET**: Generate a random string using `openssl rand -base64 32`
- **STORAGE_TYPE**: Set to `s3` for stateless file storage
- **STORAGE_S3_REGION**, **STORAGE_S3_NAME**, **STORAGE_S3_ENDPOINT**: Configure your S3 bucket details

### 2. Deploy in Portainer

1. Open Portainer and navigate to your Docker environment
2. Go to **Stacks** → **Add Stack**
3. Choose **Upload** method
4. Upload the `docker-compose.yml` file
5. In the **Environment variables** section, copy the contents of your `.env` file (or define them individually)
6. Click **Deploy the stack**

### 3. Access the Application

Once deployed, access Twenty CRM at the URL specified in `SERVER_URL`.

### 4. First Time Setup

- Ensure your RDS PostgreSQL database is accessible and the user has necessary permissions
- The application will run database migrations automatically on first startup
- Create your admin account when prompted

## Services Included

- **server**: Main Twenty CRM application (port 5529)
- **worker**: Background job processor
- **redis**: Redis cache

## Volumes

None - This is a stateless deployment using external PostgreSQL (RDS) and S3 for file storage.

## Troubleshooting

- Check container logs in Portainer if services fail to start
- Ensure all required environment variables are set
- Verify network connectivity between services

## Official Documentation

For more information, visit: https://twenty.com/developers/section/self-hosting/docker-compose