terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "8byte-devops-tf-state-836960783082"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "8byte-devops-tf-locks"
    encrypt        = true
    profile        = "8byte-dev"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}