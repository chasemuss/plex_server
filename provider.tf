# File: provider.tf
# Purpose: Configure AWS provider with region and default tags.
#          Uses default tags to automatically apply global_tags to all resources.

provider "aws" {
  region = "us-east-1"  # Chosen for lowest cost and broad availability of t3/t4g instances

  default_tags {
    tags = var.global_tags
  }
}

# Required for S3 state bucket access
provider "aws" {
  alias  = "s3_state"
  region = "us-east-1"
} 