# Docker Compose

## Purpose

Docker Compose is used to define and run the complete 8Byte application stack using a single configuration file.

The Compose configuration manages application services, infrastructure services, networking, ports, volumes, environment variables, health checks and restart policies.

## Compose File

File:

docker-compose.yml

## Application Services

| Service | Container Port | Image |
|---|---:|---|
| Frontend | 80 | 8byte-frontend:dev |
| Admin | 80 | 8byte-admin:dev |
| Gateway | 80 | 8byte-gateway:dev |
| User Auth | 3000 | 8byte-user-auth:dev |
| Catalog | 3001 | 8byte-catalog:dev |
| Order Payment | 3002 | 8byte-order-payment:dev |
| Fulfillment | 3003 | 8byte-fulfillment:dev |
| Shopping | 3004 | 8byte-shopping:dev |
| Platform | 3005 | 8byte-platform:dev |
| Inventory | 3009 | 8byte-inventory:dev |

## Infrastructure Services

| Service | Port | Purpose |
|---|---:|---|
| PostgreSQL | 5432 | Database |
| Redis Stack | 6379 | Cache / RediSearch |
| RabbitMQ | 5672 / 15672 | Messaging |
| MinIO | 9000 / 9001 | Object Storage |

## Gateway Port Mapping

The Nginx Gateway listens on port 80 inside the container.

Host mapping:

8081:80

Application URL:

http://localhost:8081

Port 80 and 8080 were already occupied on the Windows development machine, so 8081 was selected as the host port.

## Docker Network

All application services communicate through:

app-network

Docker service names are used for internal communication.

Examples:

database:5432
redis:6379
rabbitmq:5672
catalog:3001
inventory:3009

Containers should not use localhost to communicate with other containers.

## Environment Variables

Application configuration is supplied through environment variables.

Important configuration includes:

- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASSWORD
- REDIS_HOST
- REDIS_PORT
- RABBITMQ_URL
- Service URLs
- Gateway configuration
- Application secrets

Sensitive credentials should not be committed to Git.

## Volumes

Persistent Docker volumes are configured for stateful services.

Volumes:

- postgres-data
- redis-data
- rabbitmq-data
- minio-data

Volumes allow application data to survive container recreation.

## Health Checks

Health checks are configured for infrastructure dependencies.

PostgreSQL:

pg_isready

Redis:

redis-cli ping

RabbitMQ:

rabbitmq-diagnostics -q ping

Health checks help ensure dependent services start only after infrastructure becomes ready.

## Restart Policy

Services use:

restart: unless-stopped

This allows containers to restart automatically unless manually stopped.

## Common Commands

Start the stack:

docker compose up -d

Stop the stack:

docker compose down

Show containers:

docker compose ps

Show all logs:

docker compose logs

Show service logs:

docker compose logs catalog

Follow logs:

docker compose logs -f catalog

Recreate a service:

docker compose up -d --force-recreate catalog

Rebuild an image:

docker build -t 8byte-catalog:dev ./services/catalog

## Validation

Use:

docker compose ps

The expected local environment contains:

- Frontend
- Admin
- Gateway
- 7 backend microservices
- PostgreSQL
- Redis Stack
- RabbitMQ
- MinIO

Total:

14 containers

## Current Status

The Docker Compose environment has been successfully started locally.

Validated components include:

- PostgreSQL
- Redis Stack
- RabbitMQ
- MinIO
- Frontend
- Admin
- Gateway
- Backend microservices
- Catalog
- Inventory

The gateway is accessible through:

http://localhost:8081
