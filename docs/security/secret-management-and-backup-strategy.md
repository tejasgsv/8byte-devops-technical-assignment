# Secret Management & Database Backup Strategy

Specification for secret handling, AWS Secrets Manager integration, and RDS PostgreSQL backup/disaster recovery procedures.

---

## 1. Secret Management Strategy

### Architectural Principle
No plaintext secrets (database passwords, API keys, JWT secrets, TLS certificates) are ever committed to Git repositories or hardcoded in Terraform code.

```text
[ Developer / CI/CD ] ──> [ AWS Secrets Manager / K8s Secret ] ──> [ EKS Application Pod ]
                             Secret Encrypted with KMS Key              Injected as Env Var
```

### 1. Terraform Parameterization
In Terraform, secrets are declared as `sensitive = true`:
```hcl
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

### 2. AWS Secrets Manager Integration
Production application secrets are stored in AWS Secrets Manager and synced into Kubernetes using the **External Secrets Operator (ESO)** or **AWS Secrets Store CSI Driver**:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-db-secret
  namespace: 8byte-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secretsmanager
    kind: ClusterSecretStore
  target:
    name: postgres-credentials
  data:
    - secretKey: password
      remoteRef:
        key: 8byte-devops/postgres/password
```

---

## 2. PostgreSQL RDS Backup & Recovery Strategy

### 1. Automated Backups
- **Frequency**: Daily automated snapshots during maintenance window (`02:00-03:00 UTC`).
- **Retention**: 7 days (`backup_retention_period = 7`).
- **Encryption**: Snapshots are encrypted using AWS KMS managed key.

### 2. Manual Snapshots (Pre-Deployment SOP)
Before applying major database migrations or schema updates:
```powershell
aws rds create-db-snapshot `
  --db-instance-identifier postgres-8byte-devops `
  --db-snapshot-identifier postgres-8byte-devops-pre-migration-$(Get-Date -Format "yyyyMMdd-HHmm") `
  --region ap-south-1 `
  --profile 8byte-dev
```

### 3. Point-In-Time Recovery (PITR)
Supports restoring the database to any second within the retention period:
```powershell
aws rds restore-db-instance-to-point-in-time `
  --source-db-instance-identifier postgres-8byte-devops `
  --target-db-instance-identifier postgres-8byte-devops-restored `
  --restore-time 2026-08-30T15:00:00.000Z `
  --region ap-south-1 `
  --profile 8byte-dev
```
