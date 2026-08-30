# Amazon ECR Repositories

locals {
  ecr_repositories = [
    "gateway",
    "frontend",
    "admin",
    "user-auth",
    "catalog",
    "order-payment",
    "fulfillment",
    "shopping",
    "platform",
    "inventory"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.ecr_repositories)

  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name    = "${var.project_name}/${each.value}"
    Project = var.project_name
    Service = each.value
  }
}