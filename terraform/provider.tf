# terraform/provider.tf
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "chasemuss-west-2"  # replace with your S3 bucket
    key            = "terraform.tfstate"
    region         = "us-west-2"
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