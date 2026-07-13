output "repository_arns" {
  description = "ECR repository ARNs by repository name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.arn }
}

output "repository_urls" {
  description = "ECR repository URLs by repository name."
  value       = { for name, repository in aws_ecr_repository.this : name => repository.repository_url }
}

output "repository_names" {
  description = "ECR repository names."
  value       = keys(aws_ecr_repository.this)
}
