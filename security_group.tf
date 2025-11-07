# File: security_group.tf
# Purpose: Define security group with only necessary inbound rules.
#          Plex needs 32400 open. SSH optional for debugging (restrict to your IP).

resource "aws_security_group" "plex_sg" {
  name        = "plex-security-group"
  description = "Security group for Plex Media Server"
  vpc_id      = aws_vpc.plex_vpc.id

  # Plex main port
  ingress {
    description = "Plex Media Server"
    from_port   = 32400
    to_port     = 32400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Required for remote access; use CloudFront or VPN for better security
  }

  # Optional: SSH for management (restrict to your IP)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR.IP.ADD.RESS/32"]  # REPLACE WITH YOUR IP
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.global_tags, {
    Name = "plex-sg"
  })
} 