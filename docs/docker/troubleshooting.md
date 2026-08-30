# Docker Troubleshooting

This document records the Docker and Docker Compose issues encountered during the local deployment of the 8Byte application.

## Issue 1: PostgreSQL Container Unhealthy

### Error

Database is uninitialized and superuser password is not specified.

### Cause

The PostgreSQL container requires POSTGRES_PASSWORD during first-time initialization.

### Solution

The Compose database service was configured with:

POSTGRES_DB:

POSTGRES_USER:

POSTGRES_PASSWORD:

After correcting the environment configuration, PostgreSQL became healthy.

### Validation

docker compose ps

Expected:

8byte-database ... healthy

---

## Issue 2: Host Port 80 Already in Use

### Error

Bind for 0.0.0.0:80 failed.

### Investigation

PowerShell was used to identify the process listening on port 80:

Get-NetTCPConnection -LocalPort 80 -State Listen

Port 80 was already occupied on the Windows host.

### Solution

The gateway mapping was changed from:

80:80

to:

8080:80

---

## Issue 3: Host Port 8080 Already in Use

### Error

Bind for 0.0.0.0:8080 failed: port is already allocated.

### Investigation

The following command showed that port 8080 was already being used:

Get-NetTCPConnection -LocalPort 8080 -State Listen

### Solution

The gateway host port was changed to 8081:

8081:80

The Nginx container continues to listen on port 80.

The application is accessed through:

http://localhost:8081

---

## Issue 4: Inventory Container Restarting

### Symptom

The inventory container repeatedly restarted.

### Investigation

Container logs were checked:

docker compose logs inventory --tail=50

The application source was checked and a syntax issue was identified in the inventory route.

### Solution

The inventory index.js file was corrected.

Syntax validation was performed:

node --check services/inventory/src/index.js

The image was rebuilt:

docker build -t 8byte-inventory:dev ./services/inventory

The service was recreated:

docker compose up -d --force-recreate inventory

### Result

Inventory successfully started and connected to:

- Redis
- RabbitMQ
- PostgreSQL

---

## Issue 5: Catalog Container Restarting

### Symptom

The Catalog service was restarting because it required RediSearch functionality.

### Investigation

Catalog logs showed:

- Redis connection
- RediSearch connection
- RabbitMQ connection
- Database initialization

The application required RediSearch functionality that was not provided by the basic Redis image.

### Solution

The Redis image was changed from:

redis:7-alpine

to:

redis/redis-stack-server:latest

### Result

Redis became healthy and Catalog successfully initialized its RediSearch index.

Catalog status:

Running

Catalog port:

3001

---

## Useful Debugging Commands

Check all services:

docker compose ps

Check service logs:

docker compose logs SERVICE_NAME

Follow service logs:

docker compose logs -f SERVICE_NAME

Check a specific container:

docker ps

Inspect a container:

docker inspect CONTAINER_NAME

Check Docker images:

docker images

Check listening ports:

Get-NetTCPConnection -State Listen

Validate Node.js syntax:

node --check FILE_PATH

Rebuild a service:

docker build -t IMAGE_NAME ./SERVICE_PATH

Recreate a service:

docker compose up -d --force-recreate SERVICE_NAME

Restart the complete stack:

docker compose restart

Stop the complete stack:

docker compose down

Start the complete stack:

docker compose up -d

## Troubleshooting Approach

The general troubleshooting process followed in this project is:

1. Check container status.
2. Identify the failed service.
3. Check container logs.
4. Identify the root cause.
5. Validate configuration or source code.
6. Rebuild the affected image if required.
7. Recreate the container.
8. Check logs again.
9. Verify service health.
10. Validate the complete Compose stack.

## Current Result

The major Docker startup issues encountered during the initial local deployment were resolved.

The Docker Compose environment is now running with:

- Frontend
- Admin
- Gateway
- Backend microservices
- PostgreSQL
- Redis Stack
- RabbitMQ
- MinIO
