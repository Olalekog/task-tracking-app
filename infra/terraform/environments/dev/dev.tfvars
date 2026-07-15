region = "us-east-1"

aws_assume_role_arn = "arn:aws:iam::866934333672:role/Reactjs-application-role"

name         = "task-tracking-dev"
cluster_name = "task-tracking-dev-eks"

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
]

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.100.0/24",
  "10.0.101.0/24",
  "10.0.102.0/24",
]

private_subnet_cidrs = [
  "10.0.110.0/24",
  "10.0.111.0/24",
  "10.0.112.0/24",
]

internet_route_cidr = "0.0.0.0/0"
nat_gateway_count   = 1

worker_desired_size   = 2
worker_min_size       = 2
worker_max_size       = 4
worker_instance_types = ["t3.medium"]

tags = {
  Environment = "dev"
  Repository  = "task-tracking-app"
  ManagedBy   = "terraform"
}

variable "eks_endpoint_public_access" {
  description = "Temporarily enable restricted public EKS access."
  type        = bool
  default     = false
}

variable "eks_public_access_cidrs" {
  description = "CIDRs allowed to reach the public EKS endpoint."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.eks_public_access_cidrs :
      cidr != "0.0.0.0/0" && cidr != "::/0"
    ])

    error_message = "EKS public access cannot allow the entire internet."
  }
}
