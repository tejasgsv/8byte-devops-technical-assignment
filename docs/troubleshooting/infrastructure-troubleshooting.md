# Infrastructure & Application Troubleshooting Guide

Diagnostic procedures, common error resolutions, and commands for debugging Terraform, AWS, and EKS issues.

---

## 1. Terraform Troubleshooting

### Error: `No valid credential sources found` or `ValidationException`
- **Cause**: AWS CLI profile is unauthenticated or credentials expired.
- **Resolution**:
  ```powershell
  aws sso login --profile 8byte-dev
  aws sts get-caller-identity --profile 8byte-dev
  ```

### Error: `Error acquiring the state lock`
- **Cause**: A previous Terraform run was interrupted while holding the DynamoDB lock.
- **Resolution**:
  ```powershell
  # Inspect LockID in error message, then run:
  terraform force-unlock <LOCK-ID>
  ```

### Error: `first character of "identifier" must be a letter`
- **Cause**: AWS RDS identifier starts with a number.
- **Resolution**: Ensure RDS identifier begins with a letter (e.g. `postgres-8byte-devops`).

---

## 2. Amazon EKS Troubleshooting

### Pods Stuck in `ImagePullBackOff` or `ErrImagePull`
- **Cause**: ECR image missing or worker nodes lack ECR read permissions.
- **Resolution**:
  1. Verify worker node IAM role includes `AmazonEC2ContainerRegistryReadOnly`.
  2. Verify image tag exists in ECR:
     ```powershell
     aws ecr list-images --repository-name 8byte-devops/catalog --region ap-south-1 --profile 8byte-dev
     ```

### Pod Cannot Connect to PostgreSQL RDS (`Connection Refused` / `Timeout`)
- **Cause**: Security group rule missing or incorrect DB endpoint.
- **Resolution**:
  1. Check RDS endpoint in Terraform outputs:
     ```powershell
     cd terraform
     terraform output rds_endpoint
     ```
  2. Verify RDS Security Group allows port 5432 from EKS Nodes Security Group.
  3. Test connectivity from inside a debug pod:
     ```powershell
     kubectl run nettest --rm -it --image=busybox -- nc -zv postgres-8byte-devops.c12345.ap-south-1.rds.amazonaws.com 5432
     ```
