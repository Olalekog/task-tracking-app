variable "name" {
  description = "Name prefix for the EBS CSI driver IAM role."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
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
  description = "Kubernetes namespace for the EBS CSI driver."
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Kubernetes service account name used by the EBS CSI driver controller."
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "addon_version" {
  description = "aws-ebs-csi-driver EKS addon version. Leave null to use the EKS-recommended default version."
  type        = string
  default     = null
}

variable "resolve_conflicts_on_create" {
  description = "Conflict resolution behavior when the addon is first created."
  type        = string
  default     = "OVERWRITE"
}

variable "resolve_conflicts_on_update" {
  description = "Conflict resolution behavior when the addon is updated."
  type        = string
  default     = "OVERWRITE"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
