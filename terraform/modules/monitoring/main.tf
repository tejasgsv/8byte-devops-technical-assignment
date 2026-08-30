# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-eks-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# CloudWatch Log Group for RDS PostgreSQL
resource "aws_cloudwatch_log_group" "rds" {
  name              = "/aws/rds/instance/${var.rds_instance_identifier}/postgresql"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-rds-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Metric Alarm: High RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-rds-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm triggers when RDS CPU utilization exceeds 80% for 10 minutes"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  tags = {
    Name        = "${var.project_name}-rds-high-cpu-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}
