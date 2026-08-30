# Troubleshooting Guide - 8Byte DevOps Full-Stack Application

This document contains detailed troubleshooting procedures, common error scenarios, root causes, exact diagnostic verification commands, and resolution steps for the 8Byte full-stack microservices application across local, cloud, and Kubernetes environments.

---

## 1. Systemic Troubleshooting Methodology

When an error or outage occurs, follow this structured 8-step diagnostic workflow:

```text
1. Identify Failing Component ──> 2. Check Resource Status ──> 3. Inspect Logs
                                                                     │
7. Verify Fix & Test         <── 6. Execute Root Cause Fix  <── 4. Analyze Configuration
        │                                                            │
        v                                                            v
8. Document Solution                                          5. Test Connectivity
```

### Initial Diagnostic Cheat Sheet

| Domain | First Command to Run |
| :--- | :--- |
| **AWS CLI / SSO** | `aws sts get-caller-identity --profile 8byte-dev` |
| **Terraform** | `terraform validate` & `terraform plan` |
| **Kubernetes Cluster** | `kubectl get nodes` & `kubectl get pods -A` |
| **Kubernetes Pod Error** | `kubectl logs <pod-name> -n 8byte-app` & `kubectl describe pod <pod-name> -n 8byte-app` |
| **Docker Compose** | `docker compose ps` & `docker compose logs -f <service-name>` |
| **RDS PostgreSQL** | `aws rds describe-db-instances --db-instance-identifier postgres-8byte-devops --profile 8byte-dev` |

---

## 2. Docker & Container Troubleshooting

### Scenario 2.1: Container Exits Immediately (`Exit Code 1` / `CrashLoopBackOff`)

#### 🔍 Symptoms
Container stops immediately after `docker compose up` or pod stays in `CrashLoopBackOff`.

#### 🧪 Verification Command
```powershell
docker compose logs <service-name>
# or in Kubernetes:
kubectl logs <pod-name> -n 8byte-app --previous
```

#### 📌 Root Cause
Missing environment variables (e.g. `DB_HOST`, `JWT_SECRET`), syntax error in Node.js startup file, or missing entrypoint script permissions.

#### 🛠️ Solution
1. Verify mandatory environment variables in `.env` or Kubernetes secret.
2. Check `CMD` or `ENTRYPOINT` path in `Dockerfile`.
3. Test container interactively:
   ```powershell
   docker run -it --entrypoint /bin/sh 836960783082.dkr.ecr.ap-south-1.amazonaws.com/8byte-devops/user-auth:latest
   ```

---

### Scenario 2.2: Port Conflict (`bind: address already in use`)

#### 🔍 Symptoms
`docker compose up` fails with `Error starting userland proxy: listen tcp 0.0.0.0:5432: bind: address already in use`.

#### 🧪 Verification Command
```powershell
# Windows PowerShell:
Get-NetTCPConnection -LocalPort 5432 | Select-Object LocalAddress, LocalPort, OwningProcess
Get-Process -Id <PID>
```

#### 📌 Root Cause
A local PostgreSQL database instance or another container is occupying port 5432.

#### 🛠️ Solution
Stop the conflicting process or change host port mapping in `docker-compose.yml`:
```powershell
Stop-Process -Id <PID> -Force
```

---

### Scenario 2.3: Database Connection Race Condition (`ECONNREFUSED`)

#### 🔍 Symptoms
Backend service (Catalog, User Auth, Inventory) crashes during startup because PostgreSQL, Redis, or RabbitMQ is not yet ready to accept connections.

#### 🧪 Verification Command
```powershell
docker compose logs catalog-service
```
Log output shows: `Error: connect ECONNREFUSED 127.0.0.1:5432`.

#### 📌 Root Cause
Docker container startup order does not guarantee service readiness.

#### 🛠️ Solution
Add `healthcheck` and `depends_on` condition in `docker-compose.yml`:
```yaml
services:
  postgres:
    image: postgres:15-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  catalog-service:
    depends_on:
      postgres:
        condition: service_healthy
```

---

## 3. Terraform & Infrastructure Troubleshooting

### Scenario 3.1: AWS SSO Token Expired (`ValidationException`)

#### 🔍 Symptoms
Running `terraform plan` fails with:
`Error: failed to refresh cached credentials: ValidationException: The provided authorization grant is invalid, expired, revoked, or malformed`.

#### 🧪 Verification Command
```powershell
aws sts get-caller-identity --profile 8byte-dev
```

#### 📌 Root Cause
The temporary OAuth2 token for the AWS SSO profile `8byte-dev` expired.

#### 🛠️ Solution
Re-authenticate with AWS SSO:
```powershell
aws sso login --profile 8byte-dev
aws sts get-caller-identity --profile 8byte-dev
```

---

### Scenario 3.2: DynamoDB State Lock Stuck (`Error acquiring the state lock`)

#### 🔍 Symptoms
`terraform plan` or `terraform apply` fails with:
`Error acquiring the state lock: ConditionalCheckFailedException`.

#### 🧪 Verification Command
Inspect the `Lock ID` output by Terraform (e.g., `8d22384a-f823-4411-92b1-123456789abc`).

#### 📌 Root Cause
A previous Terraform run was interrupted (e.g. CTRL+C or network loss) while holding the DynamoDB table lock (`8byte-devops-tf-locks`).

#### 🛠️ Solution
Force unlock the state after confirming no other engineer is running Terraform:
```powershell
cd terraform
terraform force-unlock <LOCK-ID>
```

---

### Scenario 3.3: Invalid RDS Identifier (`first character of "identifier" must be a letter`)

#### 🔍 Symptoms
`terraform plan` fails with: `Error: first character of "identifier" must be a letter` on `aws_db_instance.main`.

#### 📌 Root Cause
AWS RDS instance identifiers cannot start with a digit. If `project_name` is `8byte-devops`, `${var.project_name}-postgres` evaluates to `8byte-devops-postgres` which starts with `8`.

#### 🛠️ Solution
Prefix the identifier with a letter in `modules/rds/main.tf`:
```hcl
resource "aws_db_instance" "main" {
  identifier = "postgres-${var.project_name}"
}
```

---

## 4. Amazon EKS & Kubernetes Troubleshooting

### Scenario 4.1: Pod Stuck in `ImagePullBackOff`

#### 🔍 Symptoms
`kubectl get pods -n 8byte-app` shows `STATUS: ImagePullBackOff` or `ErrImagePull`.

#### 开启 Verification Command
```powershell
kubectl describe pod <pod-name> -n 8byte-app
```
Look under `Events:` for `Failed to pull image ... rpc error: code = Unknown desc = Error response from daemon: pull access denied`.

#### 📌 Root Cause
1. ECR repository URL or image tag is incorrect.
2. EKS Worker Node IAM Role lacks `AmazonEC2ContainerRegistryReadOnly` policy.

#### 🛠️ Solution
1. Verify image exists in ECR:
   ```powershell
   aws ecr list-images --repository-name 8byte-devops/catalog --profile 8byte-dev
   ```
2. Attach policy to `8byte-devops-eks-node-role` via Terraform `modules/iam/main.tf`:
   ```hcl
   resource "aws_iam_role_policy_attachment" "eks_ecr_read_only" {
     policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
     role       = aws_iam_role.eks_nodes.name
   }
   ```

---

### Scenario 4.2: EKS Nodes Not Joining Cluster (`kubectl get nodes` returns empty)

#### 🔍 Symptoms
EKS cluster control plane is active, but `kubectl get nodes` returns `No resources found`.

#### 🧪 Verification Command
```powershell
aws eks describe-nodegroup --cluster-name 8byte-devops-eks --nodegroup-name 8byte-devops-node-group --profile 8byte-dev
```

#### 📌 Root Cause
1. Worker nodes in private subnets cannot reach EKS control plane API because NAT Gateway is missing or route table lacks `0.0.0.0/0` -> `nat_gateway_id`.
2. Missing EKS subnet tags (`kubernetes.io/cluster/8byte-devops-eks = shared`).

#### 🛠️ Solution
1. Verify NAT Gateway status in `modules/vpc`:
   ```powershell
   aws ec2 describe-nat-gateways --profile 8byte-dev
   ```
2. Ensure private application subnet route table points to `aws_nat_gateway.main.id`.

---

## 5. Amazon RDS PostgreSQL Troubleshooting

### Scenario 5.1: Database Connection Timeout from EKS Pods

#### 🔍 Symptoms
Application pod logs show `ETIMEDOUT` or `could not connect to server: Connection timed out` when connecting to `rds_endpoint`.

#### 🧪 Verification Command
Run a network debugging pod inside the EKS cluster:
```powershell
kubectl run nettest --rm -it --image=busybox -n 8byte-app -- nc -zv <rds-endpoint> 5432
```

#### 📌 Root Cause
The RDS Security Group (`8byte-devops-rds-sg`) is missing an ingress rule allowing TCP port 5432 from the EKS Node Security Group (`8byte-devops-eks-nodes-sg`).

#### 🛠️ Solution
Verify security group rule in `modules/security/main.tf`:
```hcl
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL access ONLY from EKS worker nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }
}
```

---

## 6. AWS Application Load Balancer (ALB) Troubleshooting

### Scenario 6.1: ALB Ingress Fails (`FailedBuildModel` / No Load Balancer Provisioned)

#### 🔍 Symptoms
Kubernetes Ingress object exists, but `ADDRESS` column in `kubectl get ingress` remains blank.

#### 🧪 Verification Command
```powershell
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

#### 📌 Root Cause
1. AWS Load Balancer Controller pods lack IAM OIDC role permissions.
2. Public subnets are missing the required tag: `kubernetes.io/role/elb = 1`.

#### 🛠️ Solution
Add subnet tags in `modules/vpc/main.tf`:
```hcl
resource "aws_subnet" "public" {
  tags = {
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}
```

---

## 7. CloudWatch & Observability Troubleshooting

### Scenario 7.1: Missing Log Streams in CloudWatch

#### 🔍 Symptoms
CloudWatch console displays log groups `/aws/eks/8byte-devops-eks/cluster` but no log streams appear.

#### 🧪 Verification Command
```powershell
aws logs describe-log-streams --log-group-name /aws/eks/8byte-devops-eks/cluster --profile 8byte-dev
```

#### 📌 Root Cause
EKS control plane logging types (`api`, `audit`, `authenticator`) were not enabled in `aws_eks_cluster`.

#### 🛠️ Solution
Enable `enabled_cluster_log_types` in `modules/eks/main.tf`:
```hcl
resource "aws_eks_cluster" "main" {
  name                      = "${var.project_name}-eks"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
```

---

## 8. Summary Checklist for Incident Resolution

Before closing any incident ticket:
- [ ] Root cause identified and confirmed via empirical logs.
- [ ] Code/Configuration fix applied via Terraform or Kubernetes manifest (no manual console hacks).
- [ ] `terraform validate` and `terraform plan` clean.
- [ ] Verification command executed cleanly.
- [ ] Solution documented in this Troubleshooting Guide.
