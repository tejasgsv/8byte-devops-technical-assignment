variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "8byte-dev"
}

variable "aws_region" {
  description = "AWS region for the infrastructure deployment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "8byte-devops"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of Availability Zones used by subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

# EKS Cluster Variables
variable "kubernetes_version" {
  description = "Kubernetes control plane version for EKS"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_nodes" {
  description = "Desired number of worker nodes in EKS node group"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum number of worker nodes in EKS node group"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of worker nodes in EKS node group"
  type        = number
  default     = 3
}

# RDS Database Variables
variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "SecureDevOpsP@ss123"
}

variable "db_instance_class" {
  description = "Instance class for RDS PostgreSQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage size in GB for RDS PostgreSQL database"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.7"
}

# S3 Storage Variables
variable "s3_bucket_name" {
  description = "S3 bucket name for object storage (optional override)"
  type        = string
  default     = ""
}