# AWS Infrastructure Specification & Technical Documentation

This document describes the Terraform implementation of the AWS cloud infrastructure for the 8Byte DevOps Technical Assignment.

---

## 1. Overview

The AWS infrastructure is designed to host a containerized full-stack application comprising:
- React frontend & React admin application
- Nginx API Gateway
- 7 backend microservices (Auth, Catalog, Order & Payment, Fulfillment, Shopping, Platform & Insights, Inventory)
- Supporting services (PostgreSQL RDS, Redis, RabbitMQ, S3 object storage, Monitoring)

The infrastructure is provisioned using Terraform v1.5+ and AWS Provider v6.0+.

---

## 2. Infrastructure Architecture

### Network Architecture (VPC)
- **VPC CIDR**: `10.0.0.0/16`
- **Region**: `ap-south-1` (Mumbai)
- **Availability Zones**: `ap-south-1a`, `ap-south-1b`

```text
10.0.0.0/16 (VPC)
├── Public Subnets (Internet Facing)
│   ├── 10.0.1.0/24 (ap-south-1a) -> ALB, NAT Gateway
│   └── 10.0.2.0/24 (ap-south-1b) -> ALB
├── Private Application Subnets (Outbound via NAT Gateway)
│   ├── 10.0.11.0/24 (ap-south-1a) -> EKS Control Plane & Worker Nodes
│   └── 10.0.12.0/24 (ap-south-1b) -> EKS Control Plane & Worker Nodes
└── Private Database Subnets (Isolated)
    ├── 10.0.21.0/24 (ap-south-1a) -> RDS PostgreSQL
    └── 10.0.22.0/24 (ap-south-1b) -> RDS PostgreSQL
```

---

## 3. Module Index & Inputs/Outputs

| Module | Source Directory | Responsibilities | Key Outputs |
| :--- | :--- | :--- | :--- |
| `vpc` | `modules/vpc` | Networking, Subnets, IGW, NAT, Route Tables | `vpc_id`, `public_subnet_ids`, `private_app_subnet_ids`, `private_db_subnet_ids` |
| `security` | `modules/security` | ALB, EKS, and RDS Security Groups | `alb_security_group_id`, `eks_nodes_security_group_id`, `rds_security_group_id` |
| `iam` | `modules/iam` | IAM Roles & Policies for EKS Cluster & Nodes | `eks_cluster_role_arn`, `eks_node_role_arn` |
| `eks` | `modules/eks` | EKS Cluster (v1.29) & Managed Node Group | `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data` |
| `rds` | `modules/rds` | PostgreSQL 15.7 Instance & DB Subnet Group | `db_instance_endpoint`, `db_instance_address`, `db_instance_port` |
| `s3` | `modules/s3` | Private Object Storage Bucket | `bucket_id`, `bucket_arn` |
| `monitoring` | `modules/monitoring` | CloudWatch Log Groups & RDS High CPU Alarm | `eks_log_group_name`, `rds_log_group_name`, `rds_cpu_alarm_arn` |

---

## 4. Operational Commands

### Pre-requisites & AWS Authentication
Ensure your AWS profile is active:
```powershell
aws sts get-caller-identity --profile 8byte-dev
```

### Terraform Commands
```powershell
cd terraform

# Format HCL files
terraform fmt -recursive

# Initialize modules
terraform init

# Validate configuration
terraform validate

# Generate dry-run plan
terraform plan

# Apply infrastructure
terraform apply
```
