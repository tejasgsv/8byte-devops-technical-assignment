# Technical Assignment Requirements & Compliance Matrix

Verification matrix evaluating compliance against the 8Byte DevOps Technical Assignment specification.

---

## 1. Assignment Requirements vs Implementation Matrix

| Requirement | Implementation Status | Terraform Module / File | Verification Method |
| :--- | :--- | :--- | :--- |
| **1. VPC with Public & Private Subnets** | ✅ **Passed** | `modules/vpc` | 6 Subnets across 2 AZs (`10.0.0.0/16`) |
| **2. EC2 OR ECS/EKS for Hosting** | ✅ **Passed** | `modules/eks`, `modules/iam` | Amazon EKS v1.29 Managed Node Group (`t3.medium`) |
| **3. RDS for PostgreSQL Database** | ✅ **Passed** | `modules/rds` | Private RDS PostgreSQL 15.7 (`db.t3.micro`) |
| **4. Security Groups & Rules** | ✅ **Passed** | `modules/security` | ALB -> EKS -> RDS (Port 5432 strictly restricted) |
| **5. Load Balancer for Frontend** | ✅ **Passed** | `modules/security`, `modules/vpc` | Public ALB SG + EKS Subnet Tags for ALB Controller |
| **6. Configurable `variables.tf`** | ✅ **Passed** | `variables.tf`, `terraform.tfvars` | Full parameterization of region, CIDRs, nodes, DB specs |
| **7. Terraform State Management** | ✅ **Passed** | `versions.tf` | S3 Remote Backend + DynamoDB State Locking |
| **8. Exported `outputs.tf`** | ✅ **Passed** | `outputs.tf` | Outputs VPC ID, subnets, EKS cluster endpoint, RDS endpoints |

---

## 2. Technical Decisions & Tradeoffs Summary

1. **EKS vs ECS**: Amazon EKS was selected because the application repository already includes containerized microservices and native Kubernetes manifests in `k8s/`.
2. **PostgreSQL RDS**: Managed RDS PostgreSQL replaces local database instances to provide automated daily snapshots, storage encryption, and seamless VPC subnet integration.
3. **Single NAT Gateway**: Configured 1 NAT Gateway in `ap-south-1a` to minimize AWS hourly charges while maintaining full outbound internet connectivity for private node groups.
