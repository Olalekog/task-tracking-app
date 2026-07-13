provider "aws" {
  region = var.region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.kubernetes.cluster_name
}

provider "kubernetes" {
  host                   = module.kubernetes.cluster_endpoint
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.cluster_endpoint
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
