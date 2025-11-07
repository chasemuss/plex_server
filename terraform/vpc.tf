# terraform/vpc.tf
# Simple default VPC for minimal cost
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "plex" {
  name        = "${local.name_prefix}-sg"
  description = "Allow Plex and SSH"
  vpc_id      = data.aws_vpc.default.id

  # Plex web UI and streaming
  ingress {
    description = "Plex Access"
    from_port   = 32400
    to_port     = 32400
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # SSH for setup (restrict!)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}