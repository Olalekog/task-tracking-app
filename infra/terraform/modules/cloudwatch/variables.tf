variable "log_groups" {
  description = "CloudWatch log groups."
  type = map(object({
    retention_in_days = number
    kms_key_id        = string
  }))
}

variable "metric_alarms" {
  description = "CloudWatch metric alarms."
  type = map(object({
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    dimensions          = map(string)
  }))
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
