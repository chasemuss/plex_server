# terraform/variables.tf

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for Plex"
  type        = string
  default     = "t3.medium"
}

variable "global_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    purpose = "plex"
  }
}

variable "plex_media_path" {
  description = "Local path to media directory"
  type        = string
  default     = "~/media"
}

# variable "allowed_ips" {
#   description = "List of CIDR blocks allowed to access Plex (your households)"
#   type        = list(string)
#   default     = [] # Populate in tfvars
# }

variable "plex_claim_token" {
  description = "Plex claim token from https://plex.tv/claim"
  type        = string
  default     = ""
  sensitive   = true
}