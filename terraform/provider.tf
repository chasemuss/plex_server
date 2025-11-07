# terraform/provider.tf
terraform {
  required_version = ">= 1.5.0"

  # State stored locally as requested
  backend "local" {
    path = "../terraform.tfstate"
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  # Apply global tags to all resources
  default_tags {
    tags = var.global_tags
  }
}