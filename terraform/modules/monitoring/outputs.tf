output "eks_log_group_name" {
  description = "CloudWatch log group name for EKS"
  value       = aws_cloudwatch_log_group.eks.name
}

output "rds_log_group_name" {
  description = "CloudWatch log group name for RDS"
  value       = aws_cloudwatch_log_group.rds.name
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS high CPU metric alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.arn
}
