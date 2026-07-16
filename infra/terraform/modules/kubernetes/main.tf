data "aws_region" "current" {}

resource "aws_eks_cluster" "this" {
  name                      = var.cluster_name
  role_arn                  = var.cluster_role_arn
  version                   = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = var.cluster_encryption_resources
  }

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "private_endpoint_https" {
  security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description       = "Allow HTTPS access to the private EKS API endpoint from the VPC"
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-private-endpoint-https"
  })
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.node_subnet_ids
  instance_types  = var.worker_instance_types

  scaling_config {
    desired_size = var.worker_desired_size
    min_size     = var.worker_min_size
    max_size     = var.worker_max_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  tags = var.tags
}


resource "terraform_data" "access_entry_authentication_mode" {
  input = {
    authentication_mode = var.authentication_mode
    cluster_name        = aws_eks_cluster.this.name
    region              = data.aws_region.current.name
  }

  triggers_replace = [
    aws_eks_cluster.this.id,
    var.admin_role_arn,
    var.authentication_mode,
    "verify-access-entry-authentication-mode-v2",
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      get_authentication_mode() {
        aws eks describe-cluster \
          --name "${self.input.cluster_name}" \
          --region "${self.input.region}" \
          --query 'cluster.accessConfig.authenticationMode' \
          --output text
      }

      current_mode="$(get_authentication_mode)"

      if [[ "$current_mode" == "API" || "$current_mode" == "API_AND_CONFIG_MAP" ]]; then
        echo "EKS cluster authentication mode already supports access entries: $current_mode"
        exit 0
      fi

      aws eks update-cluster-config \
        --name "${self.input.cluster_name}" \
        --region "${self.input.region}" \
        --access-config "authenticationMode=${self.input.authentication_mode}"

      aws eks wait cluster-active \
        --name "${self.input.cluster_name}" \
        --region "${self.input.region}"

      for attempt in $(seq 1 30); do
        current_mode="$(get_authentication_mode)"

        if [[ "$current_mode" == "API" || "$current_mode" == "API_AND_CONFIG_MAP" ]]; then
          echo "EKS cluster authentication mode now supports access entries: $current_mode"
          exit 0
        fi

        echo "Waiting for EKS authentication mode update: attempt $attempt/30, current mode is $current_mode"
        sleep 10
      done

      echo "EKS cluster authentication mode did not become ${self.input.authentication_mode}."
      exit 1
    EOT
  }
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.admin_role_arn
  type          = "STANDARD"

  depends_on = [terraform_data.access_entry_authentication_mode]
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = var.admin_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}
