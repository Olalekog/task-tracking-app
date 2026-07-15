region = "us-east-1"

aws_assume_role_arn = "arn:aws:iam::866934333672:role/Reactjs-application-role"

name         = "task-tracking-production"
cluster_name = "task-tracking-production-eks"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
]

vpc_cidr = "10.2.0.0/16"

public_subnet_cidrs = [
  "10.2.100.0/24",
  "10.2.101.0/24",
  "10.2.102.0/24",
]

private_subnet_cidrs = [
  "10.2.110.0/24",
  "10.2.111.0/24",
  "10.2.112.0/24",
]

internet_route_cidr = "0.0.0.0/0"
nat_gateway_count   = 1

kms_alias_name = "alias/task-tracking-production"
s3_bucket_name = "task-tracking-production-artifacts"

ecr_repositories = {
  "task-tracking-production-backend" = {
    image_tag_mutability           = "IMMUTABLE"
    scan_on_push                   = true
    encryption_type                = "KMS"
    kms_key_arn                    = ""
    force_delete                   = false
    lifecycle_policy_max_images    = 50
    lifecycle_policy_tag_status    = "any"
    lifecycle_policy_count_type    = "imageCountMoreThan"
    lifecycle_policy_action_type   = "expire"
    lifecycle_policy_description   = "Keep the latest production backend images"
    lifecycle_policy_rule_priority = 1
  }
  "task-tracking-production-frontend" = {
    image_tag_mutability           = "IMMUTABLE"
    scan_on_push                   = true
    encryption_type                = "KMS"
    kms_key_arn                    = ""
    force_delete                   = false
    lifecycle_policy_max_images    = 50
    lifecycle_policy_tag_status    = "any"
    lifecycle_policy_count_type    = "imageCountMoreThan"
    lifecycle_policy_action_type   = "expire"
    lifecycle_policy_description   = "Keep the latest production frontend images"
    lifecycle_policy_rule_priority = 1
  }
}

node_group_name       = "task-tracking-production-workers"
worker_desired_size   = 2
worker_min_size       = 2
worker_max_size       = 6
worker_instance_types = ["t2.micro"]

eks_cluster_log_group_name = "/aws/eks/task-tracking-production-eks/cluster"
application_log_group_name = "/aws/task-tracking/task-tracking-production/application"

tags = {
  Environment = "production"
  Repository  = "task-tracking-app"
  ManagedBy   = "terraform"
}
