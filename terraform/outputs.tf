output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL for the EKS cluster API"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "Database connection endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "Database port"
  value       = module.rds.db_instance_port
}

output "s3_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = module.s3.bucket_id
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = module.security.alb_security_group_id
}
