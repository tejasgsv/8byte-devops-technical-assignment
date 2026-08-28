# Microservices E-Commerce Application Codebase

[![React](https://img.shields.io/badge/react-%2320232a.svg?style=flat&logo=react&logoColor=%2361DAFB)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-%23316192.svg?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

> **Application Layer Baseline**

This repository contains the application source code, frontends, microservices, and database initialization logic for a modern full-stack e-commerce platform.

All cloud, Kubernetes, ArgoCD, legacy CI/CD, and IaC implementations have been isolated/removed so you can design and build your own custom infrastructure architecture from scratch using:

$$\text{Application Codebase} \longrightarrow \text{Docker} \longrightarrow \text{AWS ECR} \longrightarrow \text{Terraform} \longrightarrow \text{ALB / EC2 / ECS / RDS} \longrightarrow \text{GitHub Actions}$$

---

## 🏗️ Application Microservice Architecture

The application comprises 2 React frontends, 7 Node.js backend microservices, an Nginx API Gateway, and 3 infrastructure data stores (PostgreSQL, Redis, RabbitMQ).

```
                              ┌─────────────────────────┐
                              │     Nginx Gateway       │
                              │      (Port 3080)        │
                              └────────────┬────────────┘
                                           │
          ┌────────────────────────────────┼────────────────────────────────┐
          │                                │                                │
┌─────────▼────────┐             ┌─────────▼────────┐             ┌─────────▼────────┐
│ Customer Frontend│             │  Admin Dashboard │             │  User & Auth     │
│   (Port 80)      │             │   (Port 8080)    │             │   (Port 3000)    │
└──────────────────┘             └──────────────────┘             └────────┬─────────┘
                                                                           │
   ┌──────────────────┬──────────────────┬──────────────────┬──────────────┤
   │                  │                  │                  │              │
┌──▼────────────┐  ┌──▼────────────┐  ┌──▼────────────┐  ┌──▼──────────┐ ┌─▼───────────┐
│ Catalog       │  │ Order-Payment │  │ Fulfillment   │  │ Shopping    │ │ Inventory   │
│ (Port 3001)   │  │ (Port 3002)   │  │ (Port 3003)   │  │ (Port 3004) │ │ (Port 3006) │
└──────┬────────┘  └──────┬────────┘  └───────────────┘  └─────────────┘ └─────────────┘
       │                  │
┌──────▼────────┐  ┌──────▼────────┐
│ Platform      │  │ PostgreSQL DB │
│ (Port 3005)   │  │ (Port 5432)   │
└───────────────┘  └───────────────┘
```

---

## 🧩 Services Overview

| Service | Path | Port | Description | Tech Stack |
| :--- | :--- | :--- | :--- | :--- |
| **Gateway** | `services/gateway/` | `3080` / `80` | Nginx reverse proxy routing API requests | Nginx |
| **Frontend** | `services/frontend/` | `80` | Customer-facing React e-commerce application | React 19, Vite |
| **Admin** | `services/admin/` | `8080` | Administrative dashboard | React 19, Vite |
| **User Auth** | `services/user-auth/` | `3000` | User registration, authentication & JWT management | Node.js, Express, PostgreSQL |
| **Catalog** | `services/catalog/` | `3001` | Product management, categories, reviews | Node.js, Express, PostgreSQL, Redis |
| **Order Payment** | `services/order-payment/` | `3002` | Checkout processing & payment workflow | Node.js, Express, RabbitMQ |
| **Fulfillment** | `services/fulfillment/` | `3003` | Shipping logistics and coupon validations | Node.js, Express |
| **Shopping** | `services/shopping/` | `3004` | Shopping cart & wishlist state management | Node.js, Express, Redis |
| **Platform** | `services/platform/` | `3005` | File storage, analytics, PDF reporting | Node.js, Express |
| **Inventory** | `services/inventory/` | `3006` | Real-time product inventory tracking | Node.js, Express, PostgreSQL |

---

## 🗄️ Database & Configuration

- **Database Initialization Schema**: `database/init.sql` (Creates all tables for users, products, orders, inventory, etc.)
- **Demo Seed Data**: `database/seed_demo_data.sql` (Populates test catalog items and users)
- **Local Environment File**: `.env.development` or `.env.example`

---

## 🚀 Running the Application Locally

### Prerequisites
- Node.js 18+

### Access the application
- **Customer Frontend**: http://localhost
- **Admin Dashboard**: http://localhost:8080
- **API Gateway**: http://localhost:3080
- **User Auth API**: http://localhost:3000

### Default Credentials
- **Admin Login**: `admin@example.com` / `Admin@123`
- **User Login**: `john@example.com` / `User@123`

