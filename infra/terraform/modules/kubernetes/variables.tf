variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "cluster_role_arn" {
  description = "EKS cluster IAM role ARN."
  type        = string
}

variable "node_role_arn" {
  description = "EKS worker node IAM role ARN."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the cluster control plane."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnet IDs used by worker nodes."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API endpoint access."
  type        = bool
}

variable "endpoint_public_access" {
  description = "Enable public API endpoint access."
  type        = bool
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = []
}

variable "node_group_name" {
  description = "Managed node group name."
  type        = string
}

variable "worker_desired_size" {
  description = "Desired worker nodes."
  type        = number
}

variable "worker_min_size" {
  description = "Minimum worker nodes."
  type        = number
}

variable "worker_max_size" {
  description = "Maximum worker nodes."
  type        = number
}

variable "worker_instance_types" {
  description = "Worker instance types."
  type        = list(string)
}

variable "max_unavailable" {
  description = "Maximum unavailable workers during updates."
  type        = number
}

variable "enabled_cluster_log_types" {
  description = "Enabled EKS control plane log types."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for Kubernetes secret encryption."
  type        = string
}

variable "cluster_encryption_resources" {
  description = "Kubernetes resources encrypted by EKS."
  type        = list(string)
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode. API_AND_CONFIG_MAP allows EKS access entries while preserving aws-auth ConfigMap compatibility."
  type        = string
  default     = "API_AND_CONFIG_MAP"

  validation {
    condition     = contains(["CONFIG_MAP", "API", "API_AND_CONFIG_MAP"], var.authentication_mode)
    error_message = "authentication_mode must be one of CONFIG_MAP, API, or API_AND_CONFIG_MAP."
  }
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}


variable "admin_role_arn" {
  description = "IAM role ARN granted cluster administrator access through an EKS access entry."
  type        = string
}
