region = "us-east-1"

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

map_public_ip_on_launch = false

eks_admin_instance_type = "t2.micro"