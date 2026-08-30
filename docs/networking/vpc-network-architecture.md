# VPC Network Architecture Specification

Detailed specification of the Amazon VPC network topology, subnets, route tables, and security boundaries.

---

## 1. VPC CIDR & Subnet Layout

- **VPC CIDR**: `10.0.0.0/16`
- **Region**: `ap-south-1` (Mumbai)
- **Availability Zones**: `ap-south-1a`, `ap-south-1b`

```text
+-----------------------------------------------------------------------------------+
| VPC: 10.0.0.0/16                                                                  |
|                                                                                   |
|  +--------------------------------+   +--------------------------------+          |
|  | Public Subnet 1 (10.0.1.0/24)   |   | Public Subnet 2 (10.0.2.0/24)   |          |
|  | AZ: ap-south-1a                |   | AZ: ap-south-1b                |          |
|  | ALB, NAT Gateway               |   | ALB                            |          |
|  +--------------------------------+   +--------------------------------+          |
|                 |                                                                 |
|                 v (Outbound Traffic)                                              |
|  +--------------------------------+   +--------------------------------+          |
|  | Private App Subnet 1           |   | Private App Subnet 2           |          |
|  | (10.0.11.0/24)                 |   | (10.0.12.0/24)                 |          |
|  | AZ: ap-south-1a                |   | AZ: ap-south-1b                |          |
|  | EKS Control Plane & Nodes      |   | EKS Control Plane & Nodes      |          |
|  +--------------------------------+   +--------------------------------+          |
|                 |                                                                 |
|                 v (Port 5432 Only)                                                |
|  +--------------------------------+   +--------------------------------+          |
|  | Private DB Subnet 1            |   | Private DB Subnet 2            |          |
|  | (10.0.21.0/24)                 |   | (10.0.22.0/24)                 |          |
|  | AZ: ap-south-1a                |   | AZ: ap-south-1b                |          |
|  | RDS PostgreSQL                 |   | RDS PostgreSQL                 |          |
|  +--------------------------------+   +--------------------------------+          |
+-----------------------------------------------------------------------------------+
```

---

## 2. Route Table Configurations

### Public Route Table (`aws_route_table.public`)
- **Associated Subnets**: `10.0.1.0/24`, `10.0.2.0/24`
- **Routes**:
  - `10.0.0.0/16` -> `local`
  - `0.0.0.0/0` -> Internet Gateway (`aws_internet_gateway.main`)

### Private Application Route Table (`aws_route_table.private_app`)
- **Associated Subnets**: `10.0.11.0/24`, `10.0.12.0/24`
- **Routes**:
  - `10.0.0.0/16` -> `local`
  - `0.0.0.0/0` -> NAT Gateway (`aws_nat_gateway.main`)

### Private Database Route Table (`aws_route_table.private_db`)
- **Associated Subnets**: `10.0.21.0/24`, `10.0.22.0/24`
- **Routes**:
  - `10.0.0.0/16` -> `local`
  - *(No 0.0.0.0/0 route, preventing external inbound/outbound connectivity)*

---

## 3. Kubernetes EKS Tagging Schema

To ensure the AWS Load Balancer Controller automatically discovers subnets:
- **Public Subnets**: `kubernetes.io/role/elb = "1"`
- **Private Subnets**: `kubernetes.io/role/internal-elb = "1"`
- **Cluster Association**: `kubernetes.io/cluster/8byte-devops-eks = "shared"`
