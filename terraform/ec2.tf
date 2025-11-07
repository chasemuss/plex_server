# terraform/ec2.tf
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_ebs_volume" "plex_media" {
  availability_zone = aws_instance.plex.availability_zone
  size              = 500
  type              = "gp3"
  encrypted         = true

  tags = merge(var.global_tags, {
    Name = "${local.name_prefix}-media"
  })
}

resource "aws_volume_attachment" "plex_media" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.plex_media.id
  instance_id = aws_instance.plex.id
}

# terraform/ec2.tf (updated instance block)
resource "aws_instance" "plex" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids      = [aws_security_group.plex.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.plex.name  # Added

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # In ec2.tf user_data:
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    s3_bucket    = aws_s3_bucket.plex.id
    aws_region   = var.region
  }))

  tags = merge(var.global_tags, {
    Name = "${local.name_prefix}-server"
  })

  lifecycle {
    prevent_destroy = false
  }
}