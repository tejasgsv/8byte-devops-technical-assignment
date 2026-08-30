# Deliverable 3: Challenges Faced & Resolutions Made

Documenting key technical challenges encountered during the 8Byte DevOps assignment and the engineering resolutions applied.

---

## Challenge 1: AWS Identity Migration from Root to IAM Identity Center SSO

### Problem
Initial AWS CLI commands were executing under the AWS Account root user (`arn:aws:iam::836960783082:root`), violating cloud security best practices.

### Resolution
- Provisioned AWS IAM Identity Center (SSO) with user `tejas-admin` attached to `AdministratorAccess` permission set.
- Configured dedicated AWS CLI profile `8byte-dev` pointing to AWS Access Portal URL `https://d-90667d3cc2.awsapps.com/start`.
- Verified non-root execution via `aws sts get-caller-identity --profile 8byte-dev`.

---

## Challenge 2: AWS RDS DB Identifier Starting With a Digit

### Problem
Terraform plan failed with error: `first character of "identifier" must be a letter` on resource `aws_db_instance.main`.

### Root Cause
Project name `8byte-devops` begins with digit `8`. Concatenating `${var.project_name}-postgres` evaluated to `8byte-devops-postgres`.

### Resolution
Updated RDS instance identifier in `modules/rds/main.tf` to `postgres-${var.project_name}` (evaluating to `postgres-8byte-devops`). `terraform plan` validated with 0 errors.

---

## Challenge 3: PowerShell Script String Escaping & Hash Corruption

### Problem
BCrypt password hashes generated or injected via PowerShell were failing authentication (`401 Unauthorized`).

### Root Cause
PowerShell expands `$` signs inside double-quoted strings (e.g. `$2a$10$...`), stripping characters and corrupting the BCrypt hash string.

### Resolution
Passed BCrypt hashes using single-quoted strings or generated hashes dynamically inside the container environment using Node.js script invocation.

---

## Challenge 4: Remote State Management Bootstrap & Locking

### Problem
Migrating local Terraform state to a remote S3 backend with DynamoDB locking required pre-existing AWS resources before Terraform could execute backend initialization.

### Resolution
- Created globally unique S3 bucket `8byte-devops-tf-state-836960783082` with versioning, `AES256` SSE encryption, and public access blocks.
- Created DynamoDB lock table `8byte-devops-tf-locks` (`LockID`, `PAY_PER_REQUEST`).
- Added backend configuration block to `terraform/versions.tf` and executed `terraform init -migrate-state`.
