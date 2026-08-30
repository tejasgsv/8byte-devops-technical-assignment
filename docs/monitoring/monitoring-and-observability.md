# AWS & Kubernetes Monitoring and Observability Architecture

Observability strategy and monitoring specifications for the 8Byte microservices application.

---

## 1. Observability Strategy

The application observability framework operates across three key pillars:

```text
                        Observability Pillars
                                  │
         ┌────────────────────────┼────────────────────────┐
         │                        │                        │
     CloudWatch               Prometheus                CloudWatch
      Metrics                  & Grafana                  Logs
(RDS CPU, ALB Traffic)    (Cluster Pod Metrics)     (EKS & DB Logs)
```

---

## 2. Infrastructure Observability (CloudWatch)

### 1. CloudWatch Log Groups
Managed by Terraform module `modules/monitoring`:
- `/aws/eks/8byte-devops-eks/cluster`: Retains Kubernetes API server, audit, authenticator, controller manager, and scheduler logs (7-day retention).
- `/aws/rds/instance/postgres-8byte-devops/postgresql`: Retains PostgreSQL engine error and slow-query logs (7-day retention).

### 2. Metric Alarms
- **RDS CPU High Alarm**:
  - Metric: `AWS/RDS -> CPUUtilization`
  - Threshold: `> 80%` for 2 evaluation periods of 300 seconds (10 minutes).
  - Purpose: Triggers early warning before database performance degrades.

---

## 3. Kubernetes Pod & Application Monitoring

### Recommended Deployment Stack (Prometheus + Grafana)
1. **Prometheus Operator**: Collects pod metrics, CPU/Memory usage, and HTTP request throughput.
2. **Grafana Dashboards**:
   - **Cluster Overview**: Node CPU/Memory utilization, pod restart counts.
   - **Microservice Dashboard**: Ingress request rate, 5xx error percentage, latency percentiles ($p_{95}, p_{99}$).

---

## 4. Key Metrics to Monitor

| Resource | Metric | Critical Threshold | Action Required |
| :--- | :--- | :--- | :--- |
| **EKS Nodes** | CPU / Memory Usage | `> 85%` | Scale EKS node group or increase instance type |
| **RDS PostgreSQL** | Free Storage Space | `< 2 GB` | Increase storage allocation or purge logs |
| **ALB Ingress** | HTTP 5xx Error Rate | `> 1%` | Check microservice pod logs for crashes |
| **RabbitMQ** | Queue Depth | `> 1000 messages` | Scale consumer pods (e.g. Order-Payment, Fulfillment) |
