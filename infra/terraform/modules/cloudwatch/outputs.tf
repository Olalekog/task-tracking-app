output "log_group_names" {
  description = "CloudWatch log group names."
  value       = keys(aws_cloudwatch_log_group.this)
}
