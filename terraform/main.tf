# VPC Module: Networking & Subnets
module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

# Security Module: Security Groups & Access Rules
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# IAM Module: IAM Roles for EKS Control Plane & Worker Nodes
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# EKS Module: Amazon EKS Cluster & Managed Node Group
module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_role_arn       = module.iam.eks_cluster_role_arn
  node_role_arn          = module.iam.eks_node_role_arn
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  kubernetes_version     = var.kubernetes_version
  node_instance_types    = var.node_instance_types
  desired_nodes          = var.desired_nodes
  min_nodes              = var.min_nodes
  max_nodes              = var.max_nodes
}

# RDS Module: Private PostgreSQL Database
module "rds" {
  source = "./modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
}

# S3 Module: Private Object Storage
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.s3_bucket_name
}

# Monitoring Module: CloudWatch Logs & Alarms
module "monitoring" {
  source = "./modules/monitoring"

  project_name            = var.project_name
  environment             = var.environment
  eks_cluster_name        = module.eks.cluster_name
  rds_instance_identifier = "postgres-${var.project_name}"
}
