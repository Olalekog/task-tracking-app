variable "name" {
  description = "Name prefix for AWS Load Balancer Controller IAM resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the AWS Load Balancer Controller manages load balancers."
  type        = string
}

variable "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster."
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL for the EKS cluster."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the AWS Load Balancer Controller."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account name for the AWS Load Balancer Controller."
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "chart_version" {
  description = "AWS Load Balancer Controller Helm chart version."
  type        = string
  default     = "1.13.4"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}

variable "install_kubernetes_resources" {
  description = "Create Kubernetes and Helm resources."
  type        = bool
  default     = false
}