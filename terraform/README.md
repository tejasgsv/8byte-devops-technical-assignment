# AWS Terraform Infrastructure - 8Byte DevOps Technical Assignment

Production-minded, cost-conscious, modular Terraform infrastructure provisioning the AWS cloud environment for the containerized 8Byte microservices application.

---

## 🏛️ Architecture Overview

```
                                    +-----------------------------------+
                                    |         Internet Gateway          |
                                    +-----------------------------------+
                                                      |
                    +---------------------------------+---------------------------------+
                    |                                                                   |
                    v                                                                   v
     +------------------------------+                                    +------------------------------+
     |      Public Subnet 1         |                                    |      Public Subnet 2         |
     |        (10.0.1.0/24)         |                                    |        (10.0.2.0/24)         |
     |                              |                                    |                              |
     | [Application Load Balancer]  |                                    | [Application Load Balancer]  |
     |        [NAT Gateway]         |                                    |                              |
     +------------------------------+                                    +------------------------------+
                    |                                                                   |
                    v                                                                   v
     +------------------------------+                                    +------------------------------+
     |   Private App Subnet 1       |                                    |   Private App Subnet 2       |
     |       (10.0.11.0/24)         |                                    |       (10.0.12.0/24)         |
     |                              |                                    |                              |
     |      [EKS Worker Node]       |                                    |      [EKS Worker Node]       |
     +------------------------------+                                    +------------------------------+
                    |                                                                   |
                    v                                                                   v
     +------------------------------+                                    +------------------------------+
     |    Private DB Subnet 1       |                                    |    Private DB Subnet 2       |
     |       (10.0.21.0/24)         |                                    |       (10.0.22.0/24)         |
     |                              |                                    |                              |
     |      [RDS PostgreSQL]        | <--------------------------------> |    (Multi-AZ Subnet Group)    |
     +------------------------------+                                    +------------------------------+
```

---

## 🔒 Remote State Management

The Terraform state is securely stored and managed using AWS S3 and DynamoDB:

- **S3 Bucket**: `8byte-devops-tf-state-836960783082`
  - Versioning: Enabled
  - Server-Side Encryption: AES256
  - Public Access: Blocked (All 4 settings enabled)
- **DynamoDB State Lock Table**: `8byte-devops-tf-locks`
  - Primary Hash Key: `LockID`
  - Billing Mode: `PAY_PER_REQUEST` (On-Demand)

```hcl
terraform {
  backend "s3" {
    bucket         = "8byte-devops-tf-state-836960783082"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-devops-tf-locks"
    encrypt        = true
    profile        = "8byte-dev"
  }
}
```

---

## 📁 Directory Structure

```
terraform/
├── versions.tf         # S3 Remote Backend configuration & AWS provider version requirements
├── provider.tf         # Centralized AWS provider configuration, AWS CLI profile, and default tags
├── main.tf             # Root module composition connecting VPC, Security, IAM, EKS, RDS, S3 & Monitoring
├── variables.tf        # Top-level input variable definitions with types, descriptions, and defaults
├── outputs.tf          # Exported infrastructure endpoints, resource IDs, and cluster details
├── terraform.tfvars    # Environment-specific configuration values (dev environment)
├── .gitignore          # State file, cache, and credential exclusion rules
├── .terraform.lock.hcl  # Provider dependency lock file
│
└── modules/
    ├── vpc/            # VPC, Internet Gateway, 6 Subnets across 2 AZs, Route Tables & NAT Gateway
    ├── security/       # Layered Security Groups (ALB -> EKS Nodes -> RDS PostgreSQL)
    ├── iam/            # IAM Roles & Policy attachments for EKS Control Plane & Worker Nodes
    ├── eks/            # Amazon EKS Cluster & Managed Worker Node Group
    ├── rds/            # Private Amazon RDS PostgreSQL Instance & DB Subnet Group
    ├── s3/             # Private Amazon S3 Bucket with SSE encryption & public access block
    └── monitoring/     # CloudWatch Log Groups for EKS/RDS & RDS High CPU Metric Alarm
```

---

## 🧩 Module Breakdown

### 1. VPC Module (`modules/vpc`)
- **VPC**: `10.0.0.0/16` with DNS support and hostnames enabled.
- **Public Subnets**: `10.0.1.0/24` (AZ-a), `10.0.2.0/24` (AZ-b) tagged with `kubernetes.io/role/elb = "1"`.
- **Private Application Subnets**: `10.0.11.0/24` (AZ-a), `10.0.12.0/24` (AZ-b) tagged with `kubernetes.io/role/internal-elb = "1"`.
- **Private Database Subnets**: `10.0.21.0/24` (AZ-a), `10.0.22.0/24` (AZ-b) without direct internet access.
- **Internet Gateway & NAT Gateway**: Single NAT Gateway deployed in public subnet 1 for cost efficiency.

### 2. Security Module (`modules/security`)
- **ALB Security Group**: Accepts HTTP (80) and HTTPS (443) from `0.0.0.0/0`.
- **EKS Worker Node Security Group**: Accepts traffic from ALB SG and inter-node pod communications.
- **RDS Security Group**: Accepts PostgreSQL port `5432` **ONLY** from the EKS Worker Node Security Group.

### 3. IAM Module (`modules/iam`)
- **EKS Cluster IAM Role**: Attached to `AmazonEKSClusterPolicy`.
- **EKS Node Group IAM Role**: Attached to `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, and `AmazonEC2ContainerRegistryReadOnly`.

### 4. EKS Module (`modules/eks`)
- **EKS Control Plane**: Managed cluster (Kubernetes `1.29`) deployed in private application subnets.
- **Managed Node Group**: 2 x `t3.medium` instances in private subnets with auto-scaling bounds (`min=1`, `desired=2`, `max=3`).

### 5. RDS Module (`modules/rds`)
- **DB Subnet Group**: Composed of private database subnets across 2 AZs.
- **PostgreSQL Instance**: `db.t3.micro` with 20GB GP3 encrypted storage (`storage_encrypted = true`), non-publicly accessible.

### 6. S3 Module (`modules/s3`)
- **Private Bucket**: `8byte-devops-app-storage-dev` with all public access blocked, AES256 server-side encryption, and versioning enabled.

### 7. Monitoring Module (`modules/monitoring`)
- **Log Groups**: `/aws/eks/8byte-devops-eks/cluster` and `/aws/rds/instance/postgres-8byte-devops/postgresql`.
- **Alarm**: CloudWatch metric alarm for RDS CPU utilization exceeding 80%.

---

## 🚀 How to Run

### Prerequisites
1. Installed **Terraform v1.5+** (`terraform version`).
2. Configured **AWS CLI v2** with profile `8byte-dev` (`aws sts get-caller-identity --profile 8byte-dev`).

### Step-by-Step Workflow

```powershell
# 1. Navigate to terraform directory
cd terraform

# 2. Format code recursively
terraform fmt -recursive

# 3. Initialize modules & provider plugins
terraform init

# 4. Validate syntax and configuration integrity
terraform validate

# 5. Preview planned infrastructure changes
terraform plan

# 6. Apply configuration to provision AWS resources
terraform apply
```

---

## 🔒 Security Best Practices Implemented

- **No Public Database Access**: RDS resides strictly in private DB subnets without an Internet route.
- **Least-Privilege Security Groups**: No `0.0.0.0/0` ingress on database ports. Port 5432 is restricted strictly to the EKS worker nodes.
- **Private Application Workloads**: EKS worker nodes run inside private application subnets and communicate outbound via NAT Gateway.
- **Encrypted Data at Rest**: RDS storage and S3 bucket use AWS managed encryption.
- **No Committed Plaintext Secrets**: Sensitive variables (e.g. `db_password`) are declared as `sensitive = true` in Terraform and passed securely.

---

## 💰 Technical Assignment & Cost-Awareness Tradeoffs

| Architecture Component | Demo / Technical Assignment Setup | Production Architecture Setup | Reason for Tradeoff |
| :--- | :--- | :--- | :--- |
| **NAT Gateway** | 1 Single NAT Gateway in Public Subnet 1 | 1 NAT Gateway per Availability Zone | Saves ~$32+/month per extra NAT Gateway while retaining outbound internet access for worker nodes. |
| **EKS Worker Instance Type** | `t3.medium` (2 nodes) | `t3.large` / `m5.large` or Spot Instances | Sufficient capacity for Kubernetes system pods and assignment services without high compute costs. |
| **RDS Instance Class** | Single-AZ `db.t3.micro` | Multi-AZ `db.r6g.xlarge` with Read Replicas | Eliminates Multi-AZ RDS standby node costs while validating DB subnet group and security configuration. |
| **State Storage** | S3 Remote Backend + DynamoDB Locking | S3 Remote Backend + DynamoDB Locking | Production-grade state management configured directly in AWS account. |
