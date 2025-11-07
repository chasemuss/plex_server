# File: outputs.tf
# Purpose: Provide useful outputs for user.

output "instructions" {
  value = <<EOT
INSTRUCTIONS:
1. Upload media to s3://chasemuss-plex/media/movies/ and /tv/
2. Deploy AWS Instance Scheduler (one-time): https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/deployment.html
3. Access Plex: http://<public_ip>:32400/web
4. Server auto-starts at 08:00 UTC, stops at 00:00 UTC
5. To change schedule, update SSM document or Instance Scheduler config.
EOT
} 