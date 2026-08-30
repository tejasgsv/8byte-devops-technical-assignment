# 🛠️ Deliverable 3: Challenges Faced & Technical Resolutions Log

This document details the real-world technical challenges, investigation steps, root cause analyses, and verified resolutions encountered while containerizing, provisioning, securing, and automating the **8Byte DevOps Project**.

---

## 📌 Master Challenge Log Summary

| Challenge ID | Category | Summary | Resolution | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Issue 01** | Kubernetes | Manifest dry-run confusion | Executed active `kubectl apply` | **Resolved** |
| **Issue 03** | Auth / DB | BCrypt password hash corrupted by PowerShell `$` expansion | Wrapped hash in single quotes in Node/PS script | **Resolved** |
| **Issue 05** | PowerShell | Shell `<` redirection operator failure | Utilized `Get-Content -Raw \| kubectl exec` pipeline | **Resolved** |
| **Issue 09** | Security | AWS CLI authenticated with root account | Migrated to AWS IAM Identity Center SSO profile `8byte-dev` | **Resolved** |
| **Issue 20** | Terraform | RDS identifier invalid character (`8byte-devops`) | Updated identifier to `postgres-${var.project_name}` | **Resolved** |
| **Issue 21** | Terraform | State persistence & locking missing | Migrated to S3 Remote State & DynamoDB Locks | **Resolved** |
| **Issue 22** | CI/CD / IAM | AWS OIDC `sts:AssumeRoleWithWebIdentity` denied | Updated IAM Trust Policy condition `:sub` to `repo:tejasgsv/8byte-devops-technical-assignment:*` and attached `AdministratorAccess` | **Resolved** |
| **Issue 23** | CI/CD / ECR | ECR repository missing (`8byte-devops/frontend`) | Created `ecr.tf` in Terraform to dynamically manage all 10 repositories | **Resolved** |
| **Issue 24** | CI/CD / EKS | EKS cluster `8byte-devops-eks` not provisioned yet | Implemented cluster pre-check script in GitHub Actions (`aws eks describe-cluster`) | **Resolved** |

---

## 🔍 Deep-Dive Technical Case Studies

### 1. Challenge: AWS IAM OIDC Federation Denial (`sts:AssumeRoleWithWebIdentity`)
- **Error**: `Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity`.
- **Root Cause**: The IAM Role `GitHubActions-8Byte-Deployment` trust policy had a strict `:sub` condition matching only `environment:staging` or `environment:production`, denying branch pushes (`ref:refs/heads/ci-test` or `ref:refs/heads/main`).
- **Resolution**: Updated the AssumeRole Trust Policy condition to use `StringLike` with repository scope `repo:tejasgsv/8byte-devops-technical-assignment:*` and updated OIDC provider thumbprints (`6938fd4d98bab03faadb97b34396831e3780aea1`, `1c58a218dc27ec0077884102919ab3b44c8c2f1f`).

### 2. Challenge: Missing Amazon ECR Repositories on Container Image Push
- **Error**: `The repository with name '8byte-devops/frontend' does not exist in the registry`.
- **Root Cause**: Docker build step attempted to push images to Amazon ECR before the ECR repositories were created in AWS account `836960783082`.
- **Resolution**: Created `terraform/ecr.tf` to declare `aws_ecr_repository` resources for all 10 microservices, provisioned them via Terraform, and verified via `aws ecr describe-repositories`.

### 3. Challenge: Graceful EKS Cluster Status Pre-Check
- **Error**: `ResourceNotFoundException: No cluster found for name: 8byte-devops-eks`.
- **Root Cause**: GitHub Actions attempted `aws eks update-kubeconfig` before the EKS cluster was created in AWS region `ap-south-1`.
- **Resolution**: Added a bash cluster pre-check (`aws eks describe-cluster > /dev/null 2>&1`) in GitHub Actions so that container images are pushed safely to ECR without breaking CI execution when EKS is pending.
