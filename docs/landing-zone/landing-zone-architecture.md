# AWS Landing Zone Architecture & Governance Specification

Documenting the AWS Landing Zone foundation for the 8Byte DevOps Technical Assignment.

---

## 1. Landing Zone Overview

The AWS Landing Zone establishes the security, compliance, network topology, identity, and governance baseline required before deploying application workloads.

```text
                               AWS Organization / Account
                                           │
         ┌─────────────────────────────────┼─────────────────────────────────┐
         │                                 │                                 │
  Identity & IAM                   Network Foundation                 Security Baseline
- IAM Roles for EKS               - Single VPC (10.0.0.0/16)        - KMS Data Encryption
- SSO & Least Privilege           - 3 Subnet Tiers (2 AZs)          - S3 Public Access Block
- Service-Linked Roles            - NAT & Internet Gateways         - Security Group Isolation
```

---

## 2. Landing Zone Core Pillars

### Pillar 1: Multi-AZ Network Topology
- **VPC CIDR**: `10.0.0.0/16` in `ap-south-1`.
- **Public Tier**: Hosted in `ap-south-1a` (`10.0.1.0/24`) and `ap-south-1b` (`10.0.2.0/24`) for Internet Gateways and Load Balancers.
- **Private Application Tier**: Hosted in `ap-south-1a` (`10.0.11.0/24`) and `ap-south-1b` (`10.0.12.0/24`) with outbound NAT route for EKS worker nodes.
- **Private Database Tier**: Hosted in `ap-south-1a` (`10.0.21.0/24`) and `ap-south-1b` (`10.0.22.0/24`) with strict network isolation.

### Pillar 2: IAM & Identity Governance
- Federated AWS SSO access via IAM roles (`AdministratorAccess`, developer roles).
- Dedicated service roles:
  - `8byte-devops-eks-cluster-role` for control plane API management.
  - `8byte-devops-eks-node-role` for EC2 worker nodes (`WorkerNodePolicy`, `CNI_Policy`, `ECRReadOnly`).

### Pillar 3: Data Security & Storage Baseline
- Remote Terraform state locked in S3 (`8byte-devops-tf-state-836960783082`) with DynamoDB locking (`8byte-devops-tf-locks`).
- S3 storage bucket configured with mandatory server-side encryption (`AES256`) and bucket public access block.
- RDS PostgreSQL encrypted at rest using AWS KMS managed key (`storage_encrypted = true`).

### Pillar 4: Observability & Logging
- CloudWatch log streams enabled for EKS cluster logs and PostgreSQL database engine logs.
- CloudWatch metric alarms for proactive alerting on CPU utilization.
