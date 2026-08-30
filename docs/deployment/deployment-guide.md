# Application & Infrastructure Deployment Guide

Comprehensive guide for deploying the 8Byte microservices application to AWS EKS using Terraform and Kubernetes manifests.

---

## 1. Deployment Workflow Overview

The overall deployment follows an automated, 3-tier sequence:

```text
[ 1. Cloud Infrastructure ] ──> [ 2. Container Images ] ──> [ 3. Kubernetes Application ]
      Terraform AWS                   Build & Push to ECR               Kubernetes Manifests
  VPC, EKS, RDS, S3, SG              Docker / ECR Registry            ALB, Pods, Services, Configs
```

---

## 2. Phase 1: Provision Cloud Infrastructure (Terraform)

### Step 1: AWS Authentication
Verify active AWS CLI credentials:
```powershell
aws sts get-caller-identity --profile 8byte-dev
```

### Step 2: Initialize & Apply Terraform
```powershell
cd terraform
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### Step 3: Configure `kubectl` for EKS Cluster
Once Terraform completes, update your local `kubeconfig`:
```powershell
aws eks update-kubeconfig --name 8byte-devops-eks --region ap-south-1 --profile 8byte-dev
kubectl get nodes
```

---

## 3. Phase 2: Microservices Container Image Build (ECR)

### Step 1: Create Amazon ECR Repositories
Create ECR repositories for all containerized services:
```powershell
$services = @("gateway", "frontend", "admin", "user-auth", "catalog", "order-payment", "fulfillment", "shopping", "platform", "inventory")
foreach ($s in $services) {
    aws ecr create-repository --repository-name "8byte-devops/$s" --region ap-south-1 --profile 8byte-dev
}
```

### Step 2: Build & Push Images
```powershell
aws ecr get-login-password --region ap-south-1 --profile 8byte-dev | docker login --username AWS --password-stdin 836960783082.dkr.ecr.ap-south-1.amazonaws.com

# Example build for Gateway:
docker build -t 836960783082.dkr.ecr.ap-south-1.amazonaws.com/8byte-devops/gateway:v1.0.0 ./services/gateway
docker push 836960783082.dkr.ecr.ap-south-1.amazonaws.com/8byte-devops/gateway:v1.0.0
```

---

## 4. Phase 3: Kubernetes Workload Deployment (`k8s/`)

### Step 1: Create Namespaces & Secrets
```powershell
kubectl create namespace 8byte-app
kubectl apply -f k8s/base/secrets.yaml -n 8byte-app
```

### Step 2: Deploy Supporting Services (Redis, RabbitMQ)
```powershell
kubectl apply -f k8s/base/redis.yaml -n 8byte-app
kubectl apply -f k8s/base/rabbitmq.yaml -n 8byte-app
```

### Step 3: Deploy Microservices & Ingress (ALB Controller)
```powershell
kubectl apply -f k8s/base/microservices/ -n 8byte-app
kubectl apply -f k8s/base/ingress.yaml -n 8byte-app
```

### Step 4: Verify Deployment Status
```powershell
kubectl get pods -n 8byte-app
kubectl get svc -n 8byte-app
kubectl get ingress -n 8byte-app
```
