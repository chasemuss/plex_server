# File: ec2_schedule.tf
# Purpose: Use AWS Instance Scheduler to start/stop EC2 instance daily.
#          This ensures the server only runs 08:00–00:00 UTC, saving ~50% on compute costs.

resource "aws_ssm_document" "plex_scheduler_config" {
  name          = "Plex-Instance-Scheduler-Config"
  document_type = "Document"
  content = jsonencode({
    Version = "1.0"
    Schedules = [
      {
        Name        = "plex-daily-schedule"
        Description = "Run Plex server from 08:00 to 00:00 UTC"
        Periods = [
          {
            Name        = "running-hours"
            BeginTime   = local.start_time_utc
            EndTime     = local.stop_time_utc
            InstanceTags = [
              {
                Key   = "purpose"
                Value = "plex"
              }
            ]
          }
        ]
      }
    ]
  })
}

# Note: AWS Instance Scheduler solution must be deployed separately via AWS Console or CloudFormation.
# See: https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/welcome.html
# This SSM document defines the schedule; the solution applies it. 