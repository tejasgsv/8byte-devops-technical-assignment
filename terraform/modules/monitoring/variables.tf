variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to monitor"
  type        = string
}

variable "rds_instance_identifier" {
  description = "Identifier of the RDS instance to monitor"
  type        = string
}
