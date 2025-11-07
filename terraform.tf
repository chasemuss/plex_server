# File: terraform.tf
# Purpose: Configure Terraform backend to store state in S3 for collaboration and state locking.
#          Uses existing bucket "chasemuss-plex" with prefix for state organization.

terraform {
  backend "s3" {
    bucket         = "chasemuss-plex"
    key            = "terraform/plex-server/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-plex"  # Optional: create if needed for locking
    encrypt        = true
  }
} 