variable "instances" {
  description = "EC2 instances to create."
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
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
