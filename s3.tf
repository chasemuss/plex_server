# File: s3.tf
# Purpose: Configure S3 bucket for media storage and optional configuration files.
#          Uses existing bucket "chasemuss-plex" with organized prefixes.
#          Media goes under /media/, configs under /config/.

# Data source to reference existing bucket
data "aws_s3_bucket" "plex_storage" {
  bucket = "chasemuss-plex"
}

# Optional: Create bucket policy to allow EC2 instance read/write access (if needed)
# For simplicity and security, assume IAM role will be used instead 