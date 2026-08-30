# Deliverable 2: Approach Documentation - 8Byte DevOps Assignment

Comprehensive architectural approach documentation covering end-to-end design, infrastructure provisioning, deployment automation, security, monitoring, and cost optimization.

---

## 1. Executive Summary & Design Philosophy

The 8Byte DevOps Technical Assignment requires a production-minded yet cost-conscious AWS cloud infrastructure to host a full-stack containerized microservices application.

### Key Architectural Pillars
1. **Infrastructure as Code (IaC)**: Modular Terraform code utilizing 7 distinct modules (`vpc`, `security`, `iam`, `eks`, `rds`, `s3`, `monitoring`).
2. **Container Orchestration**: Amazon EKS (Kubernetes 1.29) chosen over ECS due to pre-existing Kubernetes manifests in `k8s/`.
3. **Database Tiering**: Amazon RDS PostgreSQL in private database subnets with encryption at rest (`gp3`), non-public access, and automated backups.
4. **CI/CD Automation**: GitHub Actions pipelines with PR verification, Trivy vulnerability scanning, Amazon ECR container builds, staging auto-deployment, and production manual gate approval.
5. **Observability & Security**: CloudWatch Logs & Alarms, least-privilege Security Groups (ALB -> EKS -> RDS), and S3 state remote locking.

---

## 2. Infrastructure Architecture (Part 1)

### VPC Subnet Layout
- **CIDR**: `10.0.0.0/16` across `ap-south-1a` and `ap-south-1b`.
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24` (ALB, NAT Gateway). Tagged with `kubernetes.io/role/elb = 1`.
- **Private Application Subnets**: `10.0.11.0/24`, `10.0.12.0/24` (EKS Worker Nodes). Tagged with `kubernetes.io/role/internal-elb = 1`.
- **Private Database Subnets**: `10.0.21.0/24`, `10.0.22.0/24` (RDS PostgreSQL).

### State Management
- Remote state stored in S3 bucket `8byte-devops-tf-state-836960783082` with versioning, `AES256` server-side encryption, and public access blocks.
- Concurrent state locking handled via DynamoDB table `8byte-devops-tf-locks` (`LockID`).

---

## 3. Deployment Automation Approach (Part 2)

```text
[ Developer PR ] ──> [ PR CI Pipeline ] ──> [ Merge to Main ] ──> [ CD Staging Pipeline ] ──> [ Manual Gate ] ──> [ Production EKS ]
                        Lint & Test                                Build & Push to ECR               Approval
                     Trivy Vulnerability                       Deploy to 8byte-staging
                      Terraform Validate                         Slack Notification
```

- **PR Validation Workflow** (`pr-ci.yml`): Runs unit tests, Trivy file-system security scanning, and `terraform validate`.
- **Staging CD Workflow** (`deploy-staging.yml`): Builds microservice container images, pushes to Amazon ECR, scans images, deploys to `8byte-staging` namespace on EKS, and posts status to Slack.
- **Production CD Workflow** (`deploy-production.yml`): Uses GitHub Actions `environment: production` requiring explicit manual approval before promoting to `8byte-prod` namespace.

---

## 4. Monitoring & Observability Approach (Part 3)

- **CloudWatch Log Groups**: `/aws/eks/8byte-devops-eks/cluster` and `/aws/rds/instance/postgres-8byte-devops/postgresql`.
- **CloudWatch Metric Alarm**: Triggers on RDS CPU utilization exceeding 80% for 10 minutes.
- **Application & Cluster Monitoring**: Prometheus Operator collects pod metrics while Grafana visualizes request rate, latency ($p_{95}, p_{99}$), and error rates.

---

## 5. Security & Cost Optimization (Part 4)

- **Secret Management**: Passwords declared as `sensitive = true` in Terraform; application runtime secrets injected via AWS Secrets Manager or Kubernetes Secrets.
- **Cost Optimization**: Single NAT Gateway deployed for demo/assignment (saving ~$32/month per extra NAT Gateway); `t3.medium` EC2 worker nodes; `db.t3.micro` PostgreSQL instance.
- **Backup Strategy**: Daily automated RDS database snapshots with 7-day retention and point-in-time recovery support.
