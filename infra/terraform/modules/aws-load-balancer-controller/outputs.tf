output "iam_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller service account."
  value       = aws_iam_role.this.arn
}

output "helm_release_name" {
  description = "Helm release name when Terraform manages the release."
  value       = try(helm_release.this[0].name, null)
}
