variable "name" {
  description = "Name prefix for the EKS administration instance."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID for the administration instance."
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR used to restrict internal DNS and private endpoint traffic."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name attached to the administration instance."
  type        = string
}

variable "instance_type" {
  description = "Administration instance type."
  type        = string
  default     = "t3.micro"
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt the root volume."
  type        = string
}

variable "kubectl_version" {
  description = "Pinned kubectl version installed by Systems Manager."
  type        = string
  default     = "v1.31.0"
}

variable "helm_version" {
  description = "Pinned Helm version installed by Systems Manager."
  type        = string
  default     = "v3.16.4"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
