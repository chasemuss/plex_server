# File: ec2.tf
# Purpose: Launch t4g.micro (ARM) instance with Amazon Linux 2023 for lowest cost.
#          Uses Graviton processor: ~20% cheaper than x86, excellent for Plex transcoding with Quick Sync alternative.
#          EBS volume sized for OS + Plex metadata; media stored in S3 (mounted via s3fs or goofys).

data "aws_ami" "amazon_linux_2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "plex_server" {
  ami           = data.aws_ami.amazon_linux_2023_arm.id
  instance_type = "t4g.micro"  # $0.0084/hr on-demand, ~$3/month if running 16h/day = ~$1.50/month compute

  subnet_id              = aws_subnet.plex_public_subnet.id
  vpc_security_group_ids = [aws_security_group.plex_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.plex_instance_profile.name

  root_block_device {
    volume_size = 20  # GB: OS + Plex metadata + cache
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    s3_bucket = data.aws_s3_bucket.plex_storage.bucket
  }))

  tags = merge(var.global_tags, {
    Name = "plex-server"
    # Tag required by Instance Scheduler
    Schedule = "plex-daily-schedule"
  })

  # Ensure instance stops gracefully
  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# Output public IP for access
output "plex_server_public_ip" {
  value = aws_instance.plex_server.public_ip
}

output "plex_access_url" {
  value = "http://${aws_instance.plex_server.public_ip}:32400/web"
} 