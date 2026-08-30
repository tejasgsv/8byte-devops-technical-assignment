# Cloud Security & Compliance Architecture

Security framework, least-privilege access rules, data protection policies, and threat mitigation strategy.

---

## 1. Security Architecture Principles

```text
                               Defense-in-Depth
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         │                            │                            │
   Network Control              IAM Identity                 Data Protection
- Private DB Subnets          - Least Privilege             - S3 SSE-AES256
- Port 5432 Isolation         - EKS Service Roles           - RDS Storage Encryption
- ALB Ingress Boundary        - AWS SSO Federation          - State File DynamoDB Lock
```

---

## 2. Network Security Boundaries

### 1. ALB Security Group (`8byte-devops-alb-sg`)
- **Ingress**: HTTP (80) & HTTPS (443) from `0.0.0.0/0`.
- **Egress**: All traffic allowed.

### 2. EKS Worker Nodes Security Group (`8byte-devops-eks-nodes-sg`)
- **Ingress**: Traffic from ALB SG on node port range. Self-referencing ingress for inter-pod communications.
- **Egress**: All traffic outbound via NAT Gateway.

### 3. RDS Security Group (`8byte-devops-rds-sg`)
- **Ingress**: PostgreSQL port `5432` **ONLY** allowed from `8byte-devops-eks-nodes-sg`.
- **Egress**: Restricted to local VPC range (`10.0.0.0/16`).

---

## 3. Data Protection & Encryption

- **Database Encryption**: RDS PostgreSQL instance enforces `storage_encrypted = true` using AWS managed encryption.
- **Object Storage Encryption**: S3 bucket enforces default `AES256` server-side encryption (`aws_s3_bucket_server_side_encryption_configuration`).
- **Bucket Public Access Block**: All four public access block settings are explicitly enabled (`block_public_acls`, `ignore_public_acls`, `block_public_policy`, `restrict_public_buckets`).
- **Secrets Management**: Sensitive values (e.g. `db_password`) marked `sensitive = true` in Terraform schema and excluded from git repository.
