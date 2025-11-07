# File: variables.tf
# Purpose: Define global variables used across all modules and resources.
#          Centralizes configuration for easier management and reuse.

variable "global_tags" {
  description = "Global tags applied to all taggable AWS resources"
  type        = map(string)
  default = {
    purpose = "plex"
  }
}

# Local values for time-based scheduling (UTC times)
# 08:00 UTC to 00:00 UTC = 8 AM to midnight UTC
# This covers most US time zones during evening hours when viewing is likely
locals {
  start_time_utc = "08:00"
  stop_time_utc  = "00:00"
}

# Output to confirm schedule
output "plex_server_schedule" {
  value = "Server runs daily from ${local.start_time_utc} UTC to ${local.stop_time_utc} UTC (16 hours/day)"
} 