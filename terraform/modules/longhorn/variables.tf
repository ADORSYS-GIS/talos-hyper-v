variable "longhorn_version" {
  description = "Version of the Longhorn Helm chart to deploy."
  type        = string
  default     = "1.10.0"
}

variable "longhorn_trim_groups" {
  description = "A list of Longhorn volume groups to apply the filesystem trim recurring job to."
  type        = list(string)
}

variable "trim_cron_schedule" {
  description = "The Cron expression for the trim job schedule (e.g., '0 2 * * *' for daily at 2 AM)."
  type        = string

  validation {
    # CRITICAL: Validate the string has 5 or 6 fields separated by spaces.
    condition     = can(regex("^(?:\\S+\\s){4}\\S+(?:\\s\\S+)?$", var.trim_cron_schedule))
    error_message = "The trim_cron_schedule must be a valid Cron expression with 5 or 6 space-separated fields."
  }
}
