# terraform/s3.tf
# Create the central S3 bucket for media, scripts, and logs
resource "aws_s3_bucket" "plex" {
  bucket = local.s3_bucket # "chasemuss-plex"

  # Prevent accidental deletion
  force_destroy = false
}

# Enable versioning (recover from accidental deletes)
resource "aws_s3_bucket_versioning" "plex" {
  bucket = aws_s3_bucket.plex.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access (Plex media should NOT be public)
resource "aws_s3_bucket_public_access_block" "plex" {
  bucket = aws_s3_bucket.plex.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "plex" {
  bucket = aws_s3_bucket.plex.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Optional: Lifecycle rule to move old media to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "plex" {
  bucket = aws_s3_bucket.plex.id

  rule {
    id     = "move-to-infrequent-access"
    status = "Enabled"

    filter {
      prefix = "media/"
    }

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    # Optional: Deep Archive after 180 days
    # transition {
    #   days          = 180
    #   storage_class = "DEEP_ARCHIVE"
    # }
  }
}

# Folder structure via placeholder objects (S3 doesn't have real folders)
resource "aws_s3_object" "media_folder" {
  bucket       = aws_s3_bucket.plex.id
  key          = "media/"
  content_type = "application/x-directory"
  etag         = md5("media-folder")
}

resource "aws_s3_object" "scripts_folder" {
  bucket       = aws_s3_bucket.plex.id
  key          = "scripts/"
  content_type = "application/x-directory"
  etag         = md5("scripts-folder")
}

resource "aws_s3_object" "logs_folder" {
  bucket       = aws_s3_bucket.plex.id
  key          = "logs/"
  content_type = "application/x-directory"
  etag         = md5("logs-folder")
}

# Upload media upload script
resource "aws_s3_object" "upload_script" {
  bucket       = aws_s3_bucket.plex.id
  key          = "scripts/upload_media.py"
  source       = "../scripts/upload_media.py"
  etag         = filemd5("../scripts/upload_media.py")
  content_type = "text/x-python"
}

# Upload sync script (used on EC2)
resource "aws_s3_object" "sync_script" {
  bucket       = aws_s3_bucket.plex.id
  key          = "scripts/sync_from_s3.sh"
  source       = "../scripts/sync_from_s3.sh"
  etag         = filemd5("../scripts/sync_from_s3.sh")
  content_type = "text/x-shellscript"
}

# Optional: IAM policy for EC2 to read/write bucket
data "aws_iam_policy_document" "plex_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.plex.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.plex.arn}/*"]
  }
}

resource "aws_iam_policy" "plex_s3_access" {
  name   = "${local.name_prefix}-s3-access"
  policy = data.aws_iam_policy_document.plex_s3_policy.json
}

# Attach policy to EC2 instance role
resource "aws_iam_role" "plex_instance_role" {
  name = "${local.name_prefix}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "plex_s3_attachment" {
  role       = aws_iam_role.plex_instance_role.name
  policy_arn = aws_iam_policy.plex_s3_access.arn
}

resource "aws_iam_instance_profile" "plex" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.plex_instance_role.name
}