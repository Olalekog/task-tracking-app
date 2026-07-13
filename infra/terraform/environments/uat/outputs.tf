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

output "backend_image_url" {
  description = "Backend container image URL used in the rendered Kubernetes deployment manifest."
  value       = var.backend_image_url
}

output "frontend_image_url" {
  description = "Frontend container image URL used in the rendered Kubernetes deployment manifest."
  value       = var.frontend_image_url
}

output "rendered_kubernetes_manifest_dir" {
  description = "Directory where Terraform renders UAT Kubernetes deployment manifests."
  value       = local.rendered_manifest_dir
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
