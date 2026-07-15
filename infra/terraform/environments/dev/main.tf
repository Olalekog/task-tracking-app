locals {
  tags = merge(var.tags, { Project = var.name })

  eks_cluster_role_name = "${var.name}-eks-cluster-role"
  eks_node_role_name    = "${var.name}-eks-node-role"

  iam_roles = {
    (local.eks_cluster_role_name) = {
      assume_role_policy = {
        Statement = [{
          Effect = var.iam_trust_statement_effect
          Principal = {
            Service = var.eks_service_principal
          }
          Action = var.iam_assume_role_action
        }]
      }
      managed_policy_arns = var.eks_cluster_policy_arns
    }
    (local.eks_node_role_name) = {
      assume_role_policy = {
        Statement = [{
          Effect = var.iam_trust_statement_effect
          Principal = {
            Service = var.ec2_service_principal
          }
          Action = var.iam_assume_role_action
        }]
      }
      managed_policy_arns = var.eks_node_policy_arns
    }
  }

  cloudwatch_log_groups = length(var.cloudwatch_log_groups) > 0 ? var.cloudwatch_log_groups : {
    (var.eks_cluster_log_group_name) = {
      retention_in_days = var.cloudwatch_default_log_retention_in_days
      kms_key_id        = module.kms.key_arn
    }
    (var.application_log_group_name) = {
      retention_in_days = var.cloudwatch_default_log_retention_in_days
      kms_key_id        = module.kms.key_arn
    }
  }

  ecr_repositories = {
    for name, repository in var.ecr_repositories : name => merge(repository, {
      kms_key_arn = repository.kms_key_arn != "" ? repository.kms_key_arn : module.kms.key_arn
    })
  }
}

module "kms" {
  source = "../../modules/kms"

  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = var.kms_enable_key_rotation
  alias_name              = var.kms_alias_name
  tags                    = local.tags
}

module "vpc" {
  source = "../../modules/vpc"

  name                    = var.name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  map_public_ip_on_launch = var.map_public_ip_on_launch
  internet_route_cidr     = var.internet_route_cidr
  nat_gateway_count       = var.nat_gateway_count
  cluster_name            = var.cluster_name
  public_subnet_tags      = var.public_subnet_tags
  private_subnet_tags     = var.private_subnet_tags
  tags                    = local.tags
}

module "iam" {
  source = "../../modules/iam"

  roles          = local.iam_roles
  policy_version = var.iam_policy_version
  tags           = local.tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name             = var.s3_bucket_name
  force_destroy           = var.s3_force_destroy
  versioning_status       = var.s3_versioning_status
  kms_key_arn             = module.kms.key_arn
  sse_algorithm           = var.s3_sse_algorithm
  block_public_acls       = var.s3_public_access_block.block_public_acls
  block_public_policy     = var.s3_public_access_block.block_public_policy
  ignore_public_acls      = var.s3_public_access_block.ignore_public_acls
  restrict_public_buckets = var.s3_public_access_block.restrict_public_buckets
  tags                    = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = local.ecr_repositories
  tags         = local.tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  log_groups    = local.cloudwatch_log_groups
  metric_alarms = var.cloudwatch_metric_alarms
  tags          = local.tags
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name                 = var.cluster_name
  install_kubernetes_resources = false
  cluster_role_arn             = module.iam.role_arns[local.eks_cluster_role_name]
  node_role_arn                = module.iam.role_arns[local.eks_node_role_name]
  kubernetes_version           = var.kubernetes_version
  subnet_ids                   = module.vpc.private_subnet_ids
  node_subnet_ids              = module.vpc.private_subnet_ids
  endpoint_private_access      = true
  endpoint_public_access       = var.eks_endpoint_public_access
  public_access_cidrs          = var.eks_public_access_cidrs
  node_group_name              = var.node_group_name
  worker_desired_size          = var.worker_desired_size
  worker_min_size              = var.worker_min_size
  worker_max_size              = var.worker_max_size
  worker_instance_types        = var.worker_instance_types
  max_unavailable              = var.node_group_max_unavailable
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  kms_key_arn                  = module.kms.key_arn
  cluster_encryption_resources = ["secrets"]
  tags                         = local.tags

  depends_on = [module.iam, module.cloudwatch]
}

data "tls_certificate" "eks_oidc" {
  url = module.kubernetes.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = module.kubernetes.cluster_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  tags            = local.tags
}

module "aws_load_balancer_controller" {
  source = "../../modules/aws-load-balancer-controller"

  name              = var.name
  cluster_name      = module.kubernetes.cluster_name
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  oidc_provider_url = module.kubernetes.cluster_oidc_issuer_url
  tags              = local.tags

  depends_on = [module.kubernetes]
}

module "ec2" {
  source = "../../modules/ec2"

  instances = var.ec2_instances
  tags      = local.tags
}
