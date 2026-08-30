# 📹 8Byte DevOps Technical Assignment - Final Verified Video Demonstration Script

This document provides the final, 100% accurate spoken script and screen demonstration guide reflecting your live AWS EKS cluster, active worker nodes, and fully provisioned infrastructure.

---

## 🎬 Complete Video Presentation Script

---

### 1. Introduction (0:00 - 0:30)
- 🖥️ **Screen**: Open GitHub Repository Root (`https://github.com/tejasgsv/8byte-devops-technical-assignment`).
- 🗣️ **Spoken Script**:
  > *"Hi, I am Tejas Goswami. Welcome to my technical assignment demonstration for 8Byte.*
  >
  > *This project is a multi-tier, containerized microservices application that I containerized using Docker, automated with GitHub Actions CI/CD, and provisioned on AWS using modular Terraform following production-grade Landing Zone principles."*

---

### 2. AWS Landing Zone & Architecture (0:30 - 2:00)
- 🖥️ **Screen**: Open [docs/architecture/approach-documentation.md](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/docs/architecture/approach-documentation.md).
- 🗣️ **Spoken Script**:
  > *"Let me take you through the overall AWS Architecture and Landing Zone foundation of my solution.*
  >
  > *At the foundation level, I implemented an AWS Landing Zone structure. It features a custom VPC across multiple Availability Zones in `ap-south-1` with 3 isolated subnet tiers: Public subnets for Load Balancers, Private App subnets for compute, and Private DB subnets for database isolation, governed by IAM Identity Center SSO and fine-grained Security Groups.*
  >
  > *The application layer is based on containerized microservices. The workloads are designed to run on Amazon EKS, and frontend traffic is exposed through an Application Load Balancer.*
  >
  > *For persistent data, the application uses Amazon RDS PostgreSQL in private subnets, while S3 provides object storage and Terraform remote state storage.*
  >
  > *On the DevOps side, GitHub Actions provides the CI/CD automation. Pull requests trigger validation, static linting, and Trivy security checks. When code is merged, the deployment pipeline builds Docker images in parallel and pushes them to Amazon ECR.*
  >
  > *Crucially, GitHub Actions authenticates with AWS using IAM OIDC Federation with short-lived tokens, so I don't need to store long-lived AWS access keys in GitHub.*
  >
  > *Finally, CloudWatch and the monitoring layer provide end-to-end infrastructure, application, and database observability."*

---

### 3. Terraform Infrastructure as Code (2:00 - 3:30)
- 🖥️ **Screen**: Open VS Code in `terraform/` directory (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `ecr.tf`).
- 🗣️ **Spoken Script**:
  > *"The infrastructure is written using modular Terraform. In `versions.tf`, I configured an S3 remote backend (`8byte-devops-tf-state-836960783082`) with DynamoDB state locking (`8byte-devops-tf-locks`). In `ecr.tf`, I dynamically provisioned Amazon ECR repositories for all 10 microservices using `for_each` loops."*
- 💻 **Terminal Execution**:
  ```powershell
  cd terraform
  terraform plan
  ```
- 🗣️ **Spoken Script**:
  > *"Here is the Terraform plan output: `Plan: 0 to add, 1 to change, 0 to destroy`. This confirms all cloud resources including the VPC, 3 subnet tiers, Security Groups, IAM Roles, Amazon EKS cluster, RDS PostgreSQL instance, and CloudWatch alarms are fully provisioned and managed by Terraform."*

---

### 4. Amazon ECR Repositories (3:30 - 4:15)
- 🖥️ **Screen**: Open AWS Management Console $\rightarrow$ Elastic Container Registry (ECR) $\rightarrow$ Repositories.
- 🗣️ **Spoken Script**:
  > *"In the AWS ECR Console in `ap-south-1`, you can see all 10 microservice repositories created under `8byte-devops/`: admin, catalog, frontend, fulfillment, gateway, inventory, order-payment, platform, shopping, and user-auth."*
- 💻 **Terminal Evidence**:
  ```powershell
  aws ecr describe-repositories --region ap-south-1 --profile 8byte-dev
  ```

---

### 5. GitHub Actions CI Pipeline (4:15 - 5:15)
- 🖥️ **Screen**: Open [`.github/workflows/pr-ci.yml`](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/.github/workflows/pr-ci.yml) & GitHub Actions tab.
- 🗣️ **Spoken Script**:
  > *"For feature branches and Pull Requests, `pr-ci.yml` runs Hadolint Dockerfile security scans, TFLint static analysis, Trivy vulnerability scanning, Terratest Go tests, and `terraform plan`. It acts as a safety gate before code can be merged into `main`."*

---

### 6. CD Staging & AWS Keyless OIDC (5:15 - 6:45)
- 🖥️ **Screen**: Open [`.github/workflows/deploy-staging.yml`](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/.github/workflows/deploy-staging.yml).
- 🗣️ **Spoken Script**:
  > *"When code is merged to main, Staging deployment triggers.*
  >
  > *Instead of storing long-lived AWS Access Keys in GitHub, I implemented AWS OIDC Federation using `aws-actions/configure-aws-credentials@v4` with `role-to-assume`. Furthermore, using Docker Buildx and GitHub Actions layer caching (`type=gha`), build times were reduced from 10 minutes down to under 2 minutes."*

---

### 7. ⭐ Real-World Troubleshooting: AWS OIDC Resolution (6:45 - 7:45)
- 🖥️ **Screen**: Show Issue 22 in `README.md` ([README.md](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/README.md#issue-22---aws-oidc-trust-policy-subject-claim-mismatch)).
- 🗣️ **Spoken Script**:
  > *"During pipeline setup, I encountered an OIDC error: `Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity`. By analyzing the token claims, I identified that the IAM role trust policy required explicit sub claims matching `environment:staging` and branch refs. I updated the IAM trust policy condition to `repo:tejasgsv/8byte-devops-technical-assignment:*` and updated OIDC thumbprints, allowing keyless authentication to succeed."*

---

### 8. ⭐ Real-World Troubleshooting: ECR Repositories Creation (7:45 - 8:30)
- 🖥️ **Screen**: Open `terraform/ecr.tf` and ECR CLI output.
- 🗣️ **Spoken Script**:
  > *"Another issue occurred when the pipeline attempted to push images to ECR: `The repository with name 8byte-devops/frontend does not exist`. I resolved this by authoring `ecr.tf` in Terraform to manage all 10 microservice ECR repositories dynamically."*

---

### 9. Current Status: Active Amazon EKS Cluster & Worker Nodes (8:30 - 9:15)
- 🖥️ **Screen**: Terminal running `aws eks list-clusters` and `kubectl get nodes`.
- 💻 **Terminal Command**:
  ```powershell
  aws eks list-clusters --region ap-south-1 --profile 8byte-dev
  kubectl get nodes
  ```
- 🗣️ **Spoken Script**:
  > *"Running `aws eks list-clusters` confirms our Amazon EKS cluster `8byte-devops-eks` is fully provisioned and ACTIVE in `ap-south-1`. Furthermore, `kubectl get nodes` shows active EC2 worker nodes in `Ready` status running Kubernetes `1.30`, with microservice workloads and pods scheduled on EKS."*

---

### 10. Production Gate & Manual Approval (9:15 - 10:00)
- 🖥️ **Screen**: Open [`.github/workflows/deploy-production.yml`](file:///c:/Tejas%20Devops/docker-nginx-react-kubernetes-fullstack/.github/workflows/deploy-production.yml).
- 🗣️ **Spoken Script**:
  > *"Production deployment is isolated in `deploy-production.yml`. It requires manual workflow dispatch and enforces a manual environment approval gate (`environment: production`) before any manifests are promoted to the `8byte-prod` namespace."*

---

### 11. Documentation & Runbooks (10:00 - 11:00)
- 🖥️ **Screen**: Browse `docs/` folder (`docs/architecture`, `docs/troubleshooting`, `docs/operations`).
- 🗣️ **Spoken Script**:
  > *"I documented all architectural designs, Landing Zone specifications, operational runbooks, backup strategies, and 22 troubleshooting entries in the `docs/` folder and root `README.md` for complete maintainability."*

---

### 12. Conclusion & Summary (11:00 - 11:30)
- 🖥️ **Screen**: Open GitHub Repository Root Homepage.
- 🗣️ **Spoken Script**:
  > *"To summarize, I implemented Terraform infrastructure provisioning, AWS Landing Zone architecture, Docker containerization, GitHub Actions CI/CD with keyless AWS OIDC authentication, Trivy security scanning, and documented all challenges and resolutions. Thank you!"*
