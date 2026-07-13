variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for subnet placement."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
}

variable "map_public_ip_on_launch" {
  description = "Assign public IPs to instances launched in public subnets."
  type        = bool
}

variable "internet_route_cidr" {
  description = "CIDR used for default internet routes."
  type        = string
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways to create."
  type        = number

  validation {
    condition     = var.nat_gateway_count > 0
    error_message = "NAT gateway count must be greater than zero."
  }
}

variable "cluster_name" {
  description = "Kubernetes cluster name used for subnet discovery tags."
  type        = string
}

variable "public_subnet_tags" {
  description = "Additional public subnet tags."
  type        = map(string)
}

variable "private_subnet_tags" {
  description = "Additional private subnet tags."
  type        = map(string)
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
