# Route 53 Zone (replace with your actual hosted zone)
data "aws_route53_zone" "main" {
  name         = "strongman-software.com."
  private_zone = false
}

# Alias A record pointing to the EIP
resource "aws_route53_record" "plex" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "plex.strongman-software.com"
  type    = "A"
  ttl     = 300  # Only used if alias = false

  # Use alias to point directly to the EIP
  alias {
    name                   = aws_eip.plex_eip.public_dns
    zone_id                = aws_eip.plex_eip.hosted_zone_id
    evaluate_target_health = false
  }
}

