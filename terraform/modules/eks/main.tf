# EKS Cluster Control Plane
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_app_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name        = "${var.project_name}-eks"
    Project     = var.project_name
    Environment = var.environment
  }
}

# EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_app_subnet_ids

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "${var.project_name}-node-group"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}
