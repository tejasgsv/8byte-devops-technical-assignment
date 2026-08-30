# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "postgres-${var.project_name}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "postgres-${var.project_name}-db-subnet-group"
    Project     = var.project_name
    Environment = var.environment
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
  identifier        = "postgres-${var.project_name}"
  engine            = "postgres"
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 7

  tags = {
    Name        = "postgres-${var.project_name}"
    Project     = var.project_name
    Environment = var.environment
  }
}
