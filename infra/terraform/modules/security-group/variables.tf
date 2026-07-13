variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules."
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
}

variable "egress_rules" {
  description = "Egress rules."
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
  }))
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
