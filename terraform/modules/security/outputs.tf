output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group"
  value       = aws_security_group.alb.id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "ID of the RDS database security group"
  value       = aws_security_group.rds.id
}
