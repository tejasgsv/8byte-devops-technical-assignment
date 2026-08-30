# 📹 8Byte DevOps Technical Assignment - Video Demonstration Script

This document provides a step-by-step, 8–12 minute video recording script and presentation guide for demonstrating the **8Byte DevOps Technical Assignment**.

---

## ⏱️ Video Presentation Overview

| Section | Topic | Screen Focus | Target Duration |
| :--- | :--- | :--- | :--- |
| **1. Intro** | Project Purpose & Overview | GitHub Repository Root | 30 Seconds |
| **2. Architecture** | End-to-End System Design | Architecture Diagram in README | 1 Minute |
| **3. Terraform** | Modular IaC Setup & Plan | VS Code `terraform/` directory | 1.5 Minutes |
| **4. Amazon ECR** | Container Registries | AWS Console ECR Repositories | 45 Seconds |
| **5. GitHub CI** | PR & Feature Pipeline (`pr-ci.yml`) | GitHub Actions Runs | 1 Minute |
| **6. CD Staging** | Staging CD & Keyless OIDC | `deploy-staging.yml` & Actions | 1.5 Minutes |
| **7. OIDC Troubleshoot** | AWS IAM OIDC Trust Policy Resolution | Issue 22 in `README.md` | 1 Minute |
| **8. ECR Troubleshoot** | ECR Dynamic Creation Fix | `ecr.tf` & CLI evidence | 45 Seconds |
| **9. EKS Status** | Cluster Status & Kubeconfig Check | AWS CLI `aws eks list-clusters` | 45 Seconds |
| **10. Production Gate** | Manual Approval Workflow | `deploy-production.yml` | 45 Seconds |
| **11. Monitoring/Docs** | Runbooks & Specifications | `docs/` folder & CloudWatch | 1 Minute |
| **12. Summary** | Conclusion & Key Accomplishments | Terminal / Summary Table | 30 Seconds |

---

## 🎬 Detailed Screen-by-Screen Script

### 1. Introduction (30 Seconds)
- **Screen**: GitHub Repository Homepage (`https://github.com/tejasgsv/8byte-devops-technical-assignment`).
- **Script**:
  > *"Hi, I'm Tejas Goswami. Welcome to my video demonstration for the 8Byte DevOps Technical Assignment. In this project, I provisioned an AWS infrastructure using modular Terraform, containerized 10 microservices using Docker, automated CI/CD using GitHub Actions, integrated AWS ECR with keyless IAM OIDC authentication, and set up Kubernetes deployment manifests for Amazon EKS."*

---

### 2. Architecture & Design (1 Minute)
- **Screen**: Open [docs/architecture/approach-documentation.md](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/docs/architecture/approach-documentation.md) or architecture diagram.
- **Script**:
  > *"Here is the architecture flow. Developers push code to GitHub. GitHub Actions triggers pipelines for linting, security scans using Trivy and Hadolint, and Terraform plan execution. On merge to main, Docker images are built in parallel and pushed to Amazon ECR repositories, followed by automated deployment to Amazon EKS with RDS PostgreSQL for database persistence."*

---

### 3. Terraform Infrastructure as Code (1.5 Minutes)
- **Screen**: Open VS Code in `terraform/` directory. Show `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and `ecr.tf`.
- **Script**:
  > *"The infrastructure is written using modular Terraform. In `versions.tf`, I configured an S3 remote backend (`8byte-devops-tf-state-836960783082`) with DynamoDB state locking (`8byte-devops-tf-locks`). In `ecr.tf`, I dynamically provisioned Amazon ECR repositories for all 10 microservices using `for_each`."*
- **Terminal Execution**:
  ```powershell
  cd terraform
  terraform plan
  ```
- **Show Output**:
  > *"Here is the Terraform plan output: `Plan: 39 to add, 0 to change, 0 to destroy`. It includes the VPC, 3 subnet tiers, Security Groups, IAM Roles, Amazon EKS cluster, RDS PostgreSQL instance, and CloudWatch alarms."*

---

### 4. Amazon ECR Repositories (45 Seconds)
- **Screen**: AWS Management Console $\rightarrow$ Elastic Container Registry (ECR) $\rightarrow$ Repositories.
- **Script**:
  > *"In the AWS ECR Console in `ap-south-1`, you can see all 10 microservice repositories created under `8byte-devops/`: admin, catalog, frontend, fulfillment, gateway, inventory, order-payment, platform, shopping, and user-auth."*
- **Terminal Evidence**:
  ```powershell
  aws ecr describe-repositories --region ap-south-1 --profile 8byte-dev
  ```

---

### 5. GitHub Actions CI Pipeline (1 Minute)
- **Screen**: GitHub $\rightarrow$ Actions tab $\rightarrow$ Workflow **PR CI - Containerized Tests, Security Scan, TFLint & Terratest**.
- **Script**:
  > *"For feature branches and Pull Requests, the CI pipeline runs Hadolint Dockerfile security scans, TFLint static analysis, Trivy vulnerability scanning, Terratest Go tests, and `terraform plan`. It acts as a safety gate before any code can be merged into `main`."*

---

### 6. CD Staging & AWS Keyless OIDC (1.5 Minutes)
- **Screen**: Open `.github/workflows/deploy-staging.yml`.
- **Script**:
  > *"Instead of storing long-lived AWS Access Keys in GitHub Secrets, I implemented AWS OIDC Federation using `aws-actions/configure-aws-credentials@v4` with `role-to-assume`. The job requests a short-lived WebIdentity JWT token from GitHub's OIDC issuer. Upon authentication, microservice images are built in parallel using Docker Buildx and GitHub Actions layer caching, reducing build times from 10 minutes down to under 2 minutes."*

---

### 7. ⭐ Real-World Troubleshooting: AWS OIDC Resolution (1 Minute)
- **Screen**: Show Issue 22 in `README.md` ([README.md](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/README.md#issue-22---aws-oidc-trust-policy-subject-claim-mismatch)).
- **Script**:
  > *"During pipeline setup, I encountered an OIDC error: `Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity`. By analyzing the token claims, I identified that the IAM role trust policy required explicit sub claims matching `environment:staging` and branch refs. I updated the IAM trust policy condition to `repo:tejasgsv/8byte-devops-technical-assignment:*`, allowing keyless authentication to succeed."*

---

### 8. ⭐ Real-World Troubleshooting: ECR Repositories Creation (45 Seconds)
- **Screen**: Show `terraform/ecr.tf` and ECR CLI output.
- **Script**:
  > *"Another issue occurred when the pipeline attempted to push images to ECR: `The repository with name '8byte-devops/frontend' does not exist`. I resolved this by authoring `ecr.tf` in Terraform to manage all microservice ECR repositories dynamically."*

---

### 9. Current Status: Amazon EKS Cluster Check (45 Seconds)
- **Screen**: Terminal running `aws eks list-clusters`.
- **Script**:
  > *"To demonstrate full transparency: running `aws eks list-clusters --region ap-south-1` currently returns an empty list `{"clusters": []}` because the EKS cluster `8byte-devops-eks` has not been applied yet in this cloud account. To ensure CI pipeline reliability, I added a cluster existence pre-check in the workflow script. As soon as `terraform apply` is executed, `kubectl apply` will automatically deploy the Kubernetes manifests."*

---

### 10. Production Deployment & Manual Approval Gate (45 Seconds)
- **Screen**: Open `.github/workflows/deploy-production.yml`.
- **Script**:
  > *"Production deployment is isolated in `deploy-production.yml`. It requires manual workflow dispatch and enforces a manual environment approval gate (`environment: production`) before any manifests are promoted to the `8byte-prod` namespace."*

---

### 11. Monitoring & Comprehensive Documentation (1 Minute)
- **Screen**: Browse `docs/` directory (`docs/architecture`, `docs/troubleshooting`, `docs/operations`).
- **Script**:
  > *"I documented all architectural designs, operational runbooks, backup strategies, and 22 troubleshooting entries in the `docs/` folder and root `README.md` for complete maintainability."*

---

### 12. Conclusion & Summary (30 Seconds)
- **Screen**: GitHub Repository Homepage.
- **Script**:
  > *"To summarize, I implemented Terraform infrastructure provisioning, Docker microservice containerization, GitHub Actions CI/CD with keyless AWS OIDC authentication, Trivy security scanning, and documented all challenges and resolutions. Thank you!"*
