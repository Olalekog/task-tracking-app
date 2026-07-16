data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# trivy:ignore:AVD-AWS-0104
# HTTPS egress is required for SSM, AWS APIs, kubectl, Helm, and approved
# public chart repositories through the private subnet NAT gateway.
# trivy:ignore:AWS-0104
resource "aws_security_group" "this" {
  name        = "${var.name}-eks-admin"
  description = "Outbound-only security group for the EKS administration instance."
  vpc_id      = var.vpc_id

  egress {
    description = "HTTPS for SSM, AWS APIs, kubectl, and Helm downloads"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # existing DNS rules and tags
}

locals {
  # T2 instances do not support EBS optimization; all other current
  # generations (T3+, M-, C-, R- families, etc.) are EBS-optimized by default.
  ebs_optimized = !startswith(var.instance_type, "t2.")
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = false
  iam_instance_profile        = var.instance_profile_name
  ebs_optimized               = local.ebs_optimized
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Name                = "${var.name}-eks-admin"
    SSMManaged          = "true"
    KubernetesAdminHost = "true"
  })
}

resource "aws_ssm_document" "install_tools" {
  name            = "${var.name}-install-kubernetes-tools"
  document_type   = "Command"
  document_format = "YAML"

  content = yamlencode({
    schemaVersion = "2.2"
    description   = "Install kubectl, Helm, AWS CLI dependencies, and configure EKS kubeconfig."
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "installKubernetesTools"
        inputs = {
          runCommand = [
            "set -euo pipefail",
            "dnf install -y tar gzip unzip jq",
            "curl -fsSLo /tmp/kubectl https://dl.k8s.io/release/${var.kubectl_version}/bin/linux/amd64/kubectl",
            "install -m 0755 /tmp/kubectl /usr/local/bin/kubectl",
            "curl -fsSLo /tmp/helm.tar.gz https://get.helm.sh/helm-${var.helm_version}-linux-amd64.tar.gz",
            "tar -xzf /tmp/helm.tar.gz -C /tmp",
            "install -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm",
            "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name} --kubeconfig /root/.kube/config",
            "kubectl version --client",
            "helm version",
          ]
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_ssm_association" "install_tools" {
  name = aws_ssm_document.install_tools.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.this.id]
  }

  wait_for_success_timeout_seconds = 900
}
