aws_profile  = "8byte-dev"
aws_region   = "ap-south-1"
project_name = "8byte-devops"
environment  = "dev"

vpc_cidr                 = "10.0.0.0/16"
availability_zones       = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

kubernetes_version  = "1.30"
node_instance_types = ["t3.medium"]
desired_nodes       = 2
min_nodes           = 1
max_nodes           = 3

db_name              = "appdb"
db_username          = "postgres"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_engine_version    = "16.9"

s3_bucket_name = "8byte-devops-app-storage-dev"
