# eip.tf
resource "aws_eip" "plex_eip" {
  instance = aws_instance.plex.id  # Replace with your EC2 resource name if different
  domain   = "vpc"

  tags = merge(var.global_tags, {
    Name = "plex-static-ip"
  })

}

output "plex_eip" {
  value = aws_eip.plex_eip.public_ip
}