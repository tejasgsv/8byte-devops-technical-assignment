# Container Architecture

## Overview

The 8Byte application uses a multi-container architecture managed by Docker Compose.

The architecture separates frontend applications, API gateway, backend microservices and infrastructure services.

## Architecture Flow

User / Browser
        |
        v
NGINX API Gateway
        |
        +-------------------+
        |                   |
        v                   v
    Frontend              Admin
        |
        v
Backend Microservices
        |
        +-------------------+
        |        |          |
        v        v          v
 PostgreSQL   Redis      RabbitMQ
                           |
                           v
                         MinIO

## Gateway

Container:

8byte-gateway

Technology:

Nginx

Container port:

80

Host port:

8081

The gateway acts as the main entry point and reverse proxy for the application.

## Frontend Layer

Frontend container:

8byte-frontend

Container port:

80

Admin container:

8byte-admin

Container port:

80

The Admin application is served under the /admin path.

## Backend Layer

The application contains seven backend microservices.

### User Auth

Port:

3000

### Catalog

Port:

3001

### Order Payment

Port:

3002

### Fulfillment

Port:

3003

### Shopping

Port:

3004

### Platform

Port:

3005

### Inventory

Port:

3009

## Infrastructure Layer

### PostgreSQL

Container:

8byte-database

Port:

5432

Provides persistent relational database storage.

### Redis Stack

Container:

8byte-redis

Port:

6379

Provides caching and RediSearch functionality.

### RabbitMQ

Container:

8byte-rabbitmq

Ports:

5672 and 15672

Provides asynchronous messaging between services.

### MinIO

Container:

8byte-minio

Ports:

9000 and 9001

Provides S3-compatible object storage.

## Docker Network

Network:

app-network

All containers communicate through this Docker network.

Docker DNS allows services to communicate using service names.

Example:

catalog -> database:5432

inventory -> database:5432

catalog -> redis:6379

inventory -> rabbitmq:5672

## Persistent Storage

Persistent volumes are attached to infrastructure services.

postgres-data -> PostgreSQL

redis-data -> Redis

rabbitmq-data -> RabbitMQ

minio-data -> MinIO

## Architecture Diagram

The clean architecture diagram for this deployment is stored at:

docs/architecture/docker-compose-architecture.png

## Design Principle

The architecture separates:

1. User access
2. Reverse proxy
3. Frontend applications
4. Backend business services
5. Infrastructure dependencies
6. Persistent data

This separation makes the application easier to containerize, deploy, monitor and later migrate to Kubernetes.
