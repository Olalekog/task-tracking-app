output "cluster_name" {
  description = "EKS cluster name."
  value       = module.kubernetes.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.kubernetes.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "artifact_bucket_arn" {
  description = "Artifact bucket ARN."
  value       = module.s3.bucket_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs by repository name."
  value       = module.ecr.repository_urls
}

output "aws_load_balancer_controller_iam_role_arn" {
  description = "IAM role ARN used by the AWS Load Balancer Controller service account."
  value       = module.aws_load_balancer_controller.iam_role_arn
}

output "aws_load_balancer_controller_helm_release_name" {
  description = "Helm release name for the AWS Load Balancer Controller."
  value       = module.aws_load_balancer_controller.helm_release_name
}

output "kms_key_arn" {
  description = "KMS key ARN."
  value       = module.kms.key_arn
}

output "kubeconfig_command" {
  description = "Command for updating local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.kubernetes.cluster_name}"
}


output "eks_admin_instance_id" {
  description = "SSM-managed administration instance for the private EKS cluster."
  value       = module.eks_admin.instance_id
}

output "platform_artifact_bucket_name" {
  description = "S3 bucket used to transfer platform installation assets to the administration instance."
  value       = module.s3.bucket_id
}
