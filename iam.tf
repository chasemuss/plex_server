# File: iam.tf
# Purpose: Create IAM role and policy for EC2 instance to access S3 bucket.
#          Follows least privilege: only allow access to necessary paths in the bucket.

resource "aws_iam_role" "plex_instance_role" {
  name = "plex-ec2-s3-role"

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

  tags = var.global_tags
}

resource "aws_iam_policy" "plex_s3_access" {
  name = "plex-s3-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = data.aws_s3_bucket.plex_storage.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${data.aws_s3_bucket.plex_storage.arn}/media/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${data.aws_s3_bucket.plex_storage.arn}/config/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "plex_s3_attach" {
  role       = aws_iam_role.plex_instance_role.name
  policy_arn = aws_iam_policy.plex_s3_access.arn
}

resource "aws_iam_instance_profile" "plex_instance_profile" {
  name = "plex-instance-profile"
  role = aws_iam_role.plex_instance_role.name
} 