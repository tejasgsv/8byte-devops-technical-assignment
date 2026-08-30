# 🏗️ Deliverable 2: Architectural Approach & Strategy Documentation

This document presents the comprehensive architectural approach, design decisions, infrastructure provisioning strategy, and CI/CD automation flow for the **8Byte DevOps Technical Assignment**.

---

## 📐 1. End-to-End System Architecture

```text
                                  +--------------------------------------------------+
                                  |                 DEVELOPER / CI                   |
                                  +--------------------------------------------------+
                                                           |
                                                           v
                                  +--------------------------------------------------+
                                  |                 GITHUB REPOSITORY                |
                                  |     (tejasgsv/8byte-devops-technical-assign)    |
                                  +--------------------------------------------------+
                                                           |
                                                           v
                                  +--------------------------------------------------+
                                  |                 GITHUB ACTIONS CI/CD             |
                                  |  (Keyless AWS OIDC Federation via IAM Role)      |
                                  +--------------------------------------------------+
                                     /                   |                  \
                                    /                    |                   \
                                   v                     v                    v
                       +-------------------+   +--------------------+   +-------------------+
                       | Microservices     |   | Security & Linters |   | Terratest & TF    |
                       | Container Builds  |   | (Trivy/Hadolint/  |   | Plan Validation   |
                       | (Docker Buildx)   |   |  TFLint)           |   | (no-color plan)   |
                       +-------------------+   +--------------------+   +-------------------+
                                   \                     |                    /
                                    +--------------------+-------------------+
                                                         |
                                                         v
                                  +--------------------------------------------------+
                                  |            AMAZON ECR REPOSITORIES               |
                                  |   (8byte-devops/* microservice image tags)      |
                                  +--------------------------------------------------+
                                                         |
                                                         v
                                  +--------------------------------------------------+
                                  |             AMAZON EKS CLUSTER                   |
                                  |      (Kubernetes Workloads & Ingress Routing)    |
                                  +--------------------------------------------------+
                                            /                    \
                                           v                      v
                             +--------------------------+   +--------------------------+
                             | AWS RDS PostgreSQL       |   | AWS S3 & CloudWatch      |
                             | (Multi-AZ Data Storage)  |   | (State & Observability)  |
                             +--------------------------+   +--------------------------+
```

---

## 🏛️ 2. Key Architectural Components

### A. Infrastructure Provisioning (Terraform)
- **Modular Design**: Structured into decoupled modules (`modules/vpc`, `modules/security`, `modules/iam`, `modules/eks`, `modules/rds`, `modules/s3`, `modules/monitoring`, `ecr.tf`).
- **Remote State & Locking**: S3 backend (`8byte-devops-tf-state-836960783082`) with DynamoDB lock table (`8byte-devops-tf-locks`).
- **Dynamic ECR Management**: `ecr.tf` provisions 10 ECR repositories dynamically using `for_each` loops.

### B. CI/CD Deployment Automation (GitHub Actions)
- **Keyless OIDC Federation**: Authenticates directly with AWS STS using IAM Role `GitHubActions-8Byte-Deployment` (`sts:AssumeRoleWithWebIdentity`), eliminating long-lived static AWS access keys.
- **GitOps Flow**:
  - **Feature Branches / PRs**: Executes Hadolint, TFLint, Trivy scans, Terratest, and `terraform plan` only (non-destructive).
  - **Main Branch Push**: Builds Docker images in parallel using Buildx & layer caching (`type=gha`), pushes to Amazon ECR, and deploys to EKS Staging (`8byte-staging`).
  - **Production Promotion**: Manual workflow dispatch with environment gate (`environment: production`) deploying to `8byte-prod`.

### C. Containerized Application Workloads
- 10 Microservices: `gateway`, `frontend`, `admin`, `user-auth`, `catalog`, `order-payment`, `fulfillment`, `shopping`, `platform`, `inventory`.
- Exposed through Nginx Gateway Reverse Proxy and Ingress Controller.
