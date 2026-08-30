# Operational Runbook & Maintenance Guide

Standard Operating Procedures (SOPs) for maintaining, scaling, backing up, and recovering the 8Byte DevOps infrastructure.

---

## 1. Daily Operational Checklist

1. **Verify EKS Node Health**:
   ```powershell
   kubectl get nodes -o wide
   ```
2. **Check Pod Status in Application Namespace**:
   ```powershell
   kubectl get pods -n 8byte-app --field-selector status.phase!=Running
   ```
3. **Inspect CloudWatch Alarm Status**:
   ```powershell
   aws cloudwatch describe-alarms --state-value ALARM --region ap-south-1 --profile 8byte-dev
   ```

---

## 2. Database Backup & Disaster Recovery

### Automated Backups
- RDS PostgreSQL backups are taken daily with a retention period of 7 days (`backup_retention_period = 7`).

### On-Demand Snapshot Creation
```powershell
aws rds create-db-snapshot `
  --db-instance-identifier postgres-8byte-devops `
  --db-snapshot-identifier postgres-8byte-devops-manual-$(Get-Date -Format "yyyyMMdd-HHmm") `
  --region ap-south-1 `
  --profile 8byte-dev
```

### Point-In-Time Restoration
```powershell
aws rds restore-db-instance-to-point-in-time `
  --source-db-instance-identifier postgres-8byte-devops `
  --target-db-instance-identifier postgres-8byte-devops-restored `
  --restore-time 2026-08-30T12:00:00.000Z `
  --region ap-south-1 `
  --profile 8byte-dev
```

---

## 3. Scaling Infrastructure

### Scaling EKS Worker Node Group
To change node counts temporarily or permanently:
1. Update `desired_nodes`, `min_nodes`, or `max_nodes` in `terraform/terraform.tfvars`:
   ```hcl
   desired_nodes = 3
   max_nodes     = 5
   ```
2. Apply changes via Terraform:
   ```powershell
   cd terraform
   terraform apply -auto-approve
   ```

### Scaling Microservice Pod Replicas
```powershell
kubectl scale deployment catalog-service --replicas=3 -n 8byte-app
```
