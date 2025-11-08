# terraform/outputs.tf
output "plex_public_ip" {
  value = aws_instance.plex.public_ip
}

output "plex_url" {
  value = "http://plex.strongman-software.com:32400/web"
}

output "s3_media_prefix" {
  value = "s3://${local.s3_bucket}/media/"
}