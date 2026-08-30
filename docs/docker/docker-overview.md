# Docker Overview

## Project

8Byte Full-Stack E-Commerce Application

## Docker Implementation

This project uses Docker to containerize the application services and supporting infrastructure.

## Main Components

- Frontend
- Admin
- API Gateway
- User Authentication
- Catalog
- Order & Payment
- Fulfillment
- Shopping
- Platform
- Inventory
- PostgreSQL
- Redis
- RabbitMQ
- MinIO

## Docker Architecture

Application source code is packaged into Docker images using Dockerfiles.

Docker Compose is used to run the complete multi-container application locally.

The containers communicate with each other through the Docker Compose application network.

## Docker Flow

Source Code
    |
    v
Dockerfile
    |
    v
Docker Image
    |
    v
Docker Container
    |
    v
Docker Compose
    |
    v
Application Stack

## Current Gateway Configuration

The Nginx API Gateway is exposed on:

http://localhost:8081

Container port:

80

Port mapping:

8081:80

## Supporting Infrastructure

PostgreSQL:
- Database
- Container: 8byte-database
- Port: 5432

Redis:
- Cache / supporting service
- Container: 8byte-redis
- Port: 6379

RabbitMQ:
- Message broker
- Container: 8byte-rabbitmq
- Ports: 5672, 15672

MinIO:
- Object storage
- Container: 8byte-minio
- Ports: 9000, 9001

## Current Status

Docker Compose successfully starts the application stack.

The gateway is available through port 8081.

Database, Redis and RabbitMQ health checks are configured.

Inventory and Catalog services have been validated after resolving startup issues.
