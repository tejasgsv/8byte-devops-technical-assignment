# 8Byte DevOps Project - Troubleshooting Notes

This document records the actual issues encountered during the development, containerization, Kubernetes deployment, database setup, authentication, application testing, and AWS Terraform implementation of the 8Byte DevOps project.

Each troubleshooting entry contains:

- Problem
- Error / Symptom
- Investigation
- Root Cause
- Troubleshooting / Fix
- Verification
- Final Status

---

# Issue 01 - Kubernetes Resource Was Not Actually Deployed

## Problem

A Kubernetes manifest was validated using a dry-run command, but the expected resource was not available in the Kubernetes cluster.

## Error / Symptom

```text
deployments.apps "database" not found
```

## Investigation

The Kubernetes resources were checked:

```powershell
kubectl get deployments -n 8byte
kubectl get pods -n 8byte
```

The expected deployment was not present.

The manifest had previously been checked using:

```powershell
kubectl apply --dry-run=client -f <manifest>
```

## Root Cause

`--dry-run=client` only validates the Kubernetes manifest syntax. It does not create the resource in the cluster.

## Troubleshooting / Fix

The manifest was actually applied:

```powershell
kubectl apply -f <manifest>
```

## Verification

```powershell
kubectl get deployments -n 8byte
kubectl get pods -n 8byte
```

## Final Status

**RESOLVED** — The Kubernetes resources were deployed and became available for further testing.

---

# Issue 02 - PostgreSQL Database Initialization Verification

## Problem

The PostgreSQL database needed to be verified after Kubernetes deployment.

## Investigation

The database deployment was checked:

```powershell
kubectl get pods -n 8byte
```

Database logs were inspected:

```powershell
kubectl logs -n 8byte deploy/database --tail=200
```

## Root Cause

No application failure was identified. The database initialization process needed to be verified before testing application APIs.

## Troubleshooting / Fix

The PostgreSQL logs and database tables were inspected directly:

```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "\dt"
```

## Verification

The expected application tables were present.

## Final Status

**RESOLVED** — PostgreSQL schema initialization was verified successfully.

---

# Issue 03 - User Authentication Returned 401

## Problem

Application login was failing even though the user existed in the database.

## Error / Symptom

`401 Unauthorized` — The API returned an invalid credentials error.

## Investigation

The user record was checked directly in PostgreSQL:

```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "SELECT id,email,password_hash,role FROM users WHERE email='user@example.com';"
```

The password hash stored in the database was inspected. The authentication service uses `bcrypt`/`bcryptjs` password hashing.

## Root Cause

The stored password hash was not matching the password being supplied during authentication. During troubleshooting, special attention was required because `bcrypt` hashes contain `$` characters. PowerShell can interpret `$` inside double-quoted strings as variable expansion, corrupting the hash when passed incorrectly.

## Troubleshooting / Fix

A valid `bcrypt` hash was generated from the authentication service container:

```powershell
kubectl exec -n 8byte deploy/user-auth -- node -e "const bcrypt=require('bcryptjs'); bcrypt.hash('Admin@123',10).then(h=>console.log(h))"
```

The generated hash was stored correctly in PostgreSQL.

## Verification

The user record was checked again and the login API was re-tested.

## Final Status

**RESOLVED** — Authentication successfully returned a valid response with authentication tokens.

---

# Issue 04 - Products API Returned Empty Array

## Problem

The application was running, but the products API returned no products.

## Error / Symptom

`[]`

API test:
```powershell
kubectl exec -n 8byte deploy/gateway -- wget -qO- http://127.0.0.1/api/products
```

## Investigation

The products table count was checked directly:

```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "SELECT COUNT(*) AS product_count FROM products;"
```

Result: `product_count: 0`

## Root Cause

The products table existed, but product demo data had not been seeded. The seed data was available in `database/seed_demo_data.sql`.

## Troubleshooting / Fix

The product INSERT section was extracted into `database/products_only.sql` and loaded into PostgreSQL.

## Verification

```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "SELECT id,name,category,price,stock FROM products ORDER BY id;"
```

20 products were successfully inserted during the seed operation.

## Final Status

**RESOLVED** — Product data became available in the database.

---

# Issue 05 - PowerShell SQL Redirection Error

## Problem

The SQL file could not be imported using Linux-style input redirection in PowerShell.

## Error / Symptom

Command attempted:
```powershell
kubectl exec -i -n 8byte deploy/database -- psql -U App_user -d App_db < .\database\products_only.sql
```
PowerShell returned: `The '<' operator is reserved for future use.`

## Root Cause

The command used shell input redirection syntax (`<`) that is not supported in PowerShell.

## Troubleshooting / Fix

PowerShell pipeline input was used instead:

```powershell
Get-Content .\database\products_only.sql -Raw | kubectl exec -i -n 8byte deploy/database -- psql -U App_user -d App_db
```

## Verification

PostgreSQL returned `INSERT 0 20`.

## Final Status

**RESOLVED** — SQL data was successfully imported into the PostgreSQL database.

---

# Issue 06 - Product Seed Data Was Inserted Twice

## Problem

The product seed command was executed twice, duplicating catalog rows.

## Error / Symptom

The database contained 40 rows instead of the expected 20 demo products.

## Investigation

```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "SELECT id,name,category,price,stock FROM products ORDER BY id;"
```
Output showed duplicate product records.

## Root Cause

The seed SQL was executed more than once, and existing `ON CONFLICT DO NOTHING` logic did not trigger because product names lacked a unique constraint.

## Troubleshooting / Fix

Duplicate rows were identified and documented for idempotent seeding:

```sql
SELECT name, COUNT(*) FROM products GROUP BY name HAVING COUNT(*) > 1;
```

## Final Status

**IDENTIFIED** — Identified as a seed-data duplication issue.

---

# Issue 07 - Cart API Returned Empty Items

## Problem

The cart API returned an empty response `{"items":[]}`.

## Investigation

Tested API directly from gateway:
```powershell
kubectl exec -n 8byte deploy/gateway -- wget -qO- http://127.0.0.1/api/cart/2
```

## Root Cause

The API was reachable, but the specified user did not have items in their cart. An empty cart is a valid application state.

## Final Status

**NOT AN ERROR** — The API responded correctly.

---

# Issue 08 - Wishlist API Returned Empty Array

## Problem

The wishlist API returned an empty array `[]`.

## Investigation

Tested API directly from gateway:
```powershell
kubectl exec -n 8byte deploy/gateway -- wget -qO- http://127.0.0.1/api/wishlist/2
```

## Root Cause

The user did not have items in their wishlist.

## Final Status

**NOT AN ERROR** — The API responded correctly.

---

# Issue 09 - AWS CLI Was Using Root Identity

## Problem

AWS CLI was initially authenticated using the AWS root identity.

## Error / Symptom

`"Arn": "arn:aws:iam::836960783082:root"`

## Root Cause

AWS CLI was configured with root credentials instead of a dedicated non-root identity.

## Troubleshooting / Fix

AWS IAM Identity Center was configured with a dedicated user `tejas-admin` attached to `AdministratorAccess` permission set and mapped to AWS CLI profile `8byte-dev`.

## Verification

```powershell
aws sts get-caller-identity --profile 8byte-dev
```
Output: `"Arn": "arn:aws:sts::836960783082:assumed-role/AWSReservedSSO_AdministratorAccess.../tejas-admin"`

## Final Status

**RESOLVED** — AWS CLI authentication migrated to IAM Identity Center SSO profile `8byte-dev`.

---

# Issue 10 - AWS SSO Start URL Was Invalid

## Problem

AWS CLI SSO configuration failed during registration.

## Error / Symptom

`Invalid start url provided`

## Root Cause

Entered an AWS Console dashboard URL (`https://us-east-1.console.aws.amazon.com/...`) instead of the AWS Access Portal URL.

## Troubleshooting / Fix

Obtained the official AWS Access Portal URL (`https://d-90667d3cc2.awsapps.com/start`) from IAM Identity Center dashboard and configured `aws configure sso`.

## Final Status

**RESOLVED** — AWS SSO setup completed successfully.

---

# Issue 11 - AWS SSO User Had No AWS Account Access

## Problem

AWS CLI SSO authentication succeeded, but returned `No AWS accounts are available to you`.

## Root Cause

The IAM Identity Center user `tejas-admin` had not been assigned to the AWS Account (`836960783082`).

## Troubleshooting / Fix

Assigned user `tejas-admin` to account `836960783082` with permission set `AdministratorAccess` in IAM Identity Center.

## Final Status

**RESOLVED** — The SSO profile detected account `836960783082`.

---

# Issue 12 - AWS CLI Profile Was Not Found

## Problem

Running AWS CLI returned `The config profile (8byte-dev) could not be found`.

## Root Cause

The prior `aws configure sso` session was interrupted before saving the profile.

## Troubleshooting / Fix

Re-ran `aws configure sso` to completion and saved profile name as `8byte-dev`.

## Final Status

**RESOLVED** — Profile `8byte-dev` created and verified.

---

# Issue 13 - Terraform Could Not Find AWS Credentials

## Problem

Terraform failed during plan/apply with `Error: No valid credential sources found`.

## Root Cause

Terraform provider configuration did not specify the `profile` parameter, causing it to fall back to `default`.

## Troubleshooting / Fix

Updated `terraform/provider.tf` to explicitly reference `profile = var.aws_profile` (where `aws_profile = "8byte-dev"`):

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

## Verification

`aws sso login --profile 8byte-dev` followed by `terraform plan` authenticated cleanly.

## Final Status

**RESOLVED** — Terraform authenticated successfully with AWS CLI profile `8byte-dev`.

---

# Issue 14 - Terraform Plan Executed From Wrong Directory

## Problem

`terraform plan` failed with `Error: No configuration files`.

## Root Cause

Command was run from project root directory instead of the `terraform/` subdirectory.

## Troubleshooting / Fix

Navigated to directory: `cd terraform` before running `terraform plan`.

## Final Status

**RESOLVED** — Executed Terraform from root module directory.

---

# Issue 15 - Terraform Initialization Delay

## Problem

`terraform init` appeared stuck during provider plugin download (`Installing hashicorp/aws v6.62.0...`).

## Troubleshooting / Fix

Allowed network download to complete. Terraform initialized successfully with `hashicorp/aws v6.62.0`.

## Final Status

**RESOLVED** — Provider plugin installation completed.

---

# Issue 16 - Terraform Configuration Validation

## Problem

Terraform files required validation before plan generation.

## Troubleshooting / Fix

Ran `terraform validate` yielding `Success! The configuration is valid.`

## Final Status

**RESOLVED** — Syntax and schema validation succeeded.

---

# Issue 17 - Terraform Modular Structure Design

## Problem

Infrastructure required a maintainable modular structure separating networking, security, IAM, EKS, RDS, S3, and monitoring.

## Troubleshooting / Fix

Structured infrastructure into `modules/vpc`, `modules/security`, `modules/iam`, `modules/eks`, `modules/rds`, `modules/s3`, and `modules/monitoring`.

## Final Status

**COMPLETED** — Modular structure created and integrated in root `main.tf`.

---

# Issue 18 - Kubernetes Application vs AWS EKS Architecture Alignment

## Problem

Aligning existing Kubernetes manifests with AWS cloud infrastructure.

## Troubleshooting / Fix

Selected Amazon EKS as the cloud hosting platform since application microservices already utilize Kubernetes deployment manifests.

## Final Status

**DESIGN DECISION** — EKS adopted for cloud application hosting.

---

# Issue 19 - Landing Zone Architecture and Terraform Alignment

## Problem

Connecting documented AWS Landing Zone specification to Terraform resources.

## Troubleshooting / Fix

Organized Terraform resources into logical Landing Zone layers: IAM, Security, Networking (VPC, 3 Subnet Tiers), Compute (EKS), Data (RDS, S3), and Observability (CloudWatch).

## Final Status

**COMPLETED** — Landing zone architectural alignment documented.

---

# Issue 20 - AWS RDS Identifier Invalid Character

## Problem

`terraform plan` failed with: `Error: first character of "identifier" must be a letter` on `aws_db_instance.main`.

## Error / Symptom

`identifier = "${var.project_name}-postgres"` evaluated to `8byte-devops-postgres`.

## Root Cause

AWS RDS identifiers must begin with a letter (A-Z, a-z). `8byte-devops` starts with a digit (`8`).

## Troubleshooting / Fix

Updated `identifier` in `modules/rds/main.tf` to `postgres-${var.project_name}`:

```hcl
resource "aws_db_instance" "main" {
  identifier = "postgres-${var.project_name}"
}
```

## Verification

`terraform plan` passed with `Plan: 39 to add, 0 to change, 0 to destroy`.

## Final Status

**RESOLVED** — RDS identifier fixed and validated.

---

# Issue 21 - Terraform Remote State S3 Backend & State Locking

## Problem

Local state management needed to be upgraded to production-grade remote state with lock protection.

## Troubleshooting / Fix

Provisioned S3 state bucket (`8byte-devops-tf-state-836960783082`) with versioning, AES256 encryption, public access block, and DynamoDB lock table (`8byte-devops-tf-locks`). Configured `backend "s3"` in `versions.tf`.

## Verification

Ran `terraform init -migrate-state` and verified remote lock acquisition during `terraform plan`.

## Final Status

**RESOLVED** — Remote backend and state locking active.

---

# Issue 22 - AWS OIDC Trust Policy Subject Claim Mismatch

## Problem

GitHub Actions workflow failed during `aws-actions/configure-aws-credentials@v4` with:
`Error: Could not assume role with OIDC: Not authorized to perform sts:AssumeRoleWithWebIdentity`.

## Error / Symptom

`sts:AssumeRoleWithWebIdentity` was denied by AWS STS when running CI jobs on feature/test branches (e.g. `refs/heads/ci-test`).

## Root Cause

The AWS IAM Role `GitHubActions-8Byte-Deployment` trust policy had a strict `:sub` condition matching only `environment:staging` or `environment:production`, denying branch pushes (`ref:refs/heads/ci-test` or `ref:refs/heads/main`).

## Troubleshooting / Fix

Updated the IAM Role Assume Role Trust Policy (`AssumeRolePolicyDocument`) to use `StringLike` with repository wildcard `repo:tejasgsv/8byte-devops-technical-assignment:*`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::836960783082:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:tejasgsv/8byte-devops-technical-assignment:*"
        }
      }
    }
  ]
}
```

## Verification

Re-ran `aws iam get-role --role-name GitHubActions-8Byte-Deployment` and confirmed OIDC role assumption succeeds across GitHub Actions branches and PR events.

## Final Status

**RESOLVED** — AWS IAM OIDC trust policy updated and verified.

---

# Troubleshooting Standards

For future issues, use the following process:

1. Capture the exact error
        |
        v
2. Identify the failing component
        |
        v
3. Check status
        |
        v
4. Check logs
        |
        v
5. Verify configuration
        |
        v
6. Identify root cause
        |
        v
7. Apply minimal fix
        |
        v
8. Re-test
        |
        v
9. Record the solution

---

# Useful Verification Commands

### Docker
```powershell
docker ps
docker ps -a
docker compose ps
docker compose logs <service>
```

### Kubernetes
```powershell
kubectl get pods -n 8byte
kubectl get deployments -n 8byte
kubectl get svc -n 8byte
kubectl get endpoints -n 8byte
kubectl logs -n 8byte deploy/<service>
kubectl describe pod <pod> -n 8byte
```

### PostgreSQL
```powershell
kubectl exec -n 8byte deploy/database -- psql -U App_user -d App_db -c "\dt"
```

### AWS
```powershell
aws sts get-caller-identity --profile 8byte-dev
```

### Terraform
```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

---

# Important Security Notes

- Never commit `.env`, AWS access keys, secret keys, passwords, JWT secrets, database passwords, or Terraform state files.
- Do not use the AWS root identity for routine Terraform operations. Use the AWS IAM Identity Center SSO profile `8byte-dev`.
- Do not expose RDS PostgreSQL publicly or open port 5432 to `0.0.0.0/0`.

---

# Current Troubleshooting Status

| Issue | Status |
| :--- | :--- |
| **01 - Kubernetes resource deployment verification** | Resolved |
| **02 - PostgreSQL initialization verification** | Resolved |
| **03 - Authentication 401** | Resolved |
| **04 - Product data missing** | Resolved |
| **05 - PowerShell SQL redirection** | Resolved |
| **06 - Duplicate product seed** | Identified |
| **07 - Empty cart response** | Not an error |
| **08 - Empty wishlist response** | Not an error |
| **09 - AWS root identity usage** | Resolved |
| **10 - Invalid AWS SSO start URL** | Resolved |
| **11 - AWS SSO account assignment** | Resolved |
| **12 - AWS CLI profile missing** | Resolved |
| **13 - Terraform AWS authentication** | Resolved |
| **14 - Terraform wrong directory** | Resolved |
| **15 - Terraform initialization** | Resolved |
| **16 - Terraform validation** | Resolved |
| **17 - Terraform modular structure** | Resolved |
| **18 - EKS vs local K8s alignment** | Resolved |
| **19 - Landing Zone alignment** | Resolved |
| **20 - AWS RDS identifier naming** | Resolved |
| **21 - Terraform Remote S3 state backend** | Resolved |
| **22 - AWS OIDC Trust Policy subject claim** | Resolved |

---

# End of Troubleshooting Notes
