# S3 Bucket for private object storage
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-storage-${var.environment}"
  force_destroy = true

  tags = {
    Name        = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-storage-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket versioning configuration
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}
