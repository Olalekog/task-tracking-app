output "role_arns" {
  description = "IAM role ARNs by role name."
  value       = { for name, role in aws_iam_role.this : name => role.arn }
}

output "role_names" {
  description = "IAM role names by role name."
  value       = { for name, role in aws_iam_role.this : name => role.name }
}

output "instance_profile_arns" {
  description = "IAM instance profile ARNs by role name."
  value       = { for name, profile in aws_iam_instance_profile.this : name => profile.arn }
}

output "instance_profile_names" {
  description = "IAM instance profile names by role name."
  value       = { for name, profile in aws_iam_instance_profile.this : name => profile.name }
}
