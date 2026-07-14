variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "aws_assume_role_arn" {
  description = "Existing IAM role ARN used by Terraform AWS provider."
  type        = string
}

variable "name" {
  description = "Environment name prefix."
  type        = string
  default     = "task-tracking-dev"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "task-tracking-dev-eks"
}

variable "availability_zones" {
  description = "Availability zones for the platform."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
  default     = ["10.40.0.0/24", "10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
  default     = ["10.40.10.0/24", "10.40.11.0/24", "10.40.12.0/24"]
}

variable "enable_dns_hostnames" {
  description = "Enable VPC DNS hostnames."
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable VPC DNS support."
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Map public IPs in public subnets."
  type        = bool
  default     = true
}

variable "internet_route_cidr" {
  description = "Default internet route CIDR."
  type        = string
  default     = "0.0.0.0/0"
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways."
  type        = number
  default     = 1
}

variable "public_subnet_tags" {
  description = "Public subnet discovery tags."
  type        = map(string)
  default = {
    "kubernetes.io/role/elb" = "1"
  }
}

variable "private_subnet_tags" {
  description = "Private subnet discovery tags."
  type        = map(string)
  default = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

variable "kms_description" {
  description = "KMS key description."
  type        = string
  default     = "Task tracking app encryption key"
}

variable "kms_deletion_window_in_days" {
  description = "KMS deletion window."
  type        = number
  default     = 7
}

variable "kms_enable_key_rotation" {
  description = "Enable KMS key rotation."
  type        = bool
  default     = true
}

variable "kms_alias_name" {
  description = "KMS alias name."
  type        = string
  default     = "alias/task-tracking-dev"
}

variable "s3_bucket_name" {
  description = "S3 bucket name."
  type        = string
  default     = "task-tracking-dev-artifacts"
}

variable "s3_force_destroy" {
  description = "Allow S3 bucket force destroy."
  type        = bool
  default     = false
}

variable "s3_versioning_status" {
  description = "S3 versioning status."
  type        = string
  default     = "Enabled"
}

variable "s3_sse_algorithm" {
  description = "S3 encryption algorithm."
  type        = string
  default     = "aws:kms"
}

variable "s3_public_access_block" {
  description = "S3 public access block settings."
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "ecr_repositories" {
  description = "ECR repositories for application container images."
  type = map(object({
    image_tag_mutability           = string
    scan_on_push                   = bool
    encryption_type                = string
    kms_key_arn                    = string
    force_delete                   = bool
    lifecycle_policy_max_images    = number
    lifecycle_policy_tag_status    = string
    lifecycle_policy_count_type    = string
    lifecycle_policy_action_type   = string
    lifecycle_policy_description   = string
    lifecycle_policy_rule_priority = number
  }))
  default = {
    "task-tracking-dev-backend" = {
      image_tag_mutability           = "MUTABLE"
      scan_on_push                   = true
      encryption_type                = "KMS"
      kms_key_arn                    = ""
      force_delete                   = false
      lifecycle_policy_max_images    = 20
      lifecycle_policy_tag_status    = "any"
      lifecycle_policy_count_type    = "imageCountMoreThan"
      lifecycle_policy_action_type   = "expire"
      lifecycle_policy_description   = "Keep the latest backend images"
      lifecycle_policy_rule_priority = 1
    }
    "task-tracking-dev-frontend" = {
      image_tag_mutability           = "MUTABLE"
      scan_on_push                   = true
      encryption_type                = "KMS"
      kms_key_arn                    = ""
      force_delete                   = false
      lifecycle_policy_max_images    = 20
      lifecycle_policy_tag_status    = "any"
      lifecycle_policy_count_type    = "imageCountMoreThan"
      lifecycle_policy_action_type   = "expire"
      lifecycle_policy_description   = "Keep the latest frontend images"
      lifecycle_policy_rule_priority = 1
    }
  }
}

variable "iam_policy_version" {
  description = "IAM policy language version."
  type        = string
  default     = "2012-10-17"
}

variable "iam_trust_statement_effect" {
  description = "IAM trust policy statement effect."
  type        = string
  default     = "Allow"
}

variable "iam_assume_role_action" {
  description = "IAM action for role trust policies."
  type        = string
  default     = "sts:AssumeRole"
}

variable "eks_service_principal" {
  description = "EKS service principal."
  type        = string
  default     = "eks.amazonaws.com"
}

variable "ec2_service_principal" {
  description = "EC2 service principal."
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "eks_cluster_policy_arns" {
  description = "Managed IAM policy ARNs for EKS control plane."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

variable "eks_node_policy_arns" {
  description = "Managed IAM policy ARNs for EKS workers."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.31"
}

variable "endpoint_private_access" {
  description = "Enable private EKS endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public EKS endpoint."
  type        = bool
  default     = true
}

variable "node_group_name" {
  description = "EKS node group name."
  type        = string
  default     = "task-tracking-dev-workers"
}

variable "worker_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 2
}

variable "worker_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 2
}

variable "worker_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 4
}

variable "worker_instance_types" {
  description = "Worker node instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_max_unavailable" {
  description = "Maximum unavailable nodes during node group updates."
  type        = number
  default     = 1
}

variable "enabled_cluster_log_types" {
  description = "Enabled EKS control plane log types."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_encryption_resources" {
  description = "Kubernetes resources encrypted by KMS."
  type        = list(string)
  default     = ["secrets"]
}

variable "cloudwatch_log_groups" {
  description = "CloudWatch log groups."
  type = map(object({
    retention_in_days = number
    kms_key_id        = string
  }))
  default = {}
}

variable "cloudwatch_metric_alarms" {
  description = "CloudWatch metric alarms."
  type = map(object({
    comparison_operator = string
    evaluation_periods  = number
    metric_name         = string
    namespace           = string
    period              = number
    statistic           = string
    threshold           = number
    alarm_description   = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    dimensions          = map(string)
  }))
  default = {}
}

variable "cloudwatch_default_log_retention_in_days" {
  description = "Default CloudWatch log retention when custom log groups are not supplied."
  type        = number
  default     = 30
}

variable "eks_cluster_log_group_name" {
  description = "EKS cluster CloudWatch log group name."
  type        = string
  default     = "/aws/eks/task-tracking-dev-eks/cluster"
}

variable "application_log_group_name" {
  description = "Application CloudWatch log group name."
  type        = string
  default     = "/aws/task-tracking/task-tracking-dev/application"
}

variable "ec2_instances" {
  description = "Optional EC2 instances."
  type = map(object({
    ami                         = string
    instance_type               = string
    subnet_id                   = string
    vpc_security_group_ids      = list(string)
    associate_public_ip_address = bool
    key_name                    = string
    iam_instance_profile        = string
    user_data                   = string
    root_volume_size            = number
    root_volume_type            = string
    encrypted                   = bool
    kms_key_id                  = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    Environment = "dev"
    Repository  = "task-tracking-app"
    ManagedBy   = "terraform"
  }
}
