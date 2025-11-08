# terraform/provider.tf
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "chase-mussleman"  # replace with your S3 bucket
    key            = "terraform.tfstate"
    region         = var.region
    dynamodb_table = "plex-server-locks"            # replace with your DynamoDB table
    encrypt        = true
  }
}

provider "aws" {
  region     = var.region
  
  # Apply global tags to all resources
  default_tags {
    tags = var.global_tags
  }
}