variable "roles" {
  description = "IAM roles to create."

  type = map(object({
    description             = optional(string)
    path                    = optional(string, "/")
    max_session_duration    = optional(number, 3600)
    permissions_boundary    = optional(string)
    force_detach_policies   = optional(bool, false)
    create_instance_profile = optional(bool, false)

    assume_role_policy = object({
      Version = optional(string, "2012-10-17")
      Statement = list(object({
        Sid       = optional(string)
        Effect    = string
        Action    = any
        Principal = optional(any)
        Condition = optional(any)
      }))
    })

    managed_policy_arns = optional(list(string), [])

    inline_policies = optional(map(object({
      Version = optional(string, "2012-10-17")
      Statement = list(object({
        Sid       = optional(string)
        Effect    = string
        Action    = any
        Resource  = any
        Condition = optional(any)
      }))
    })), {})

    tags = optional(map(string), {})
  }))
}

variable "policy_version" {
  description = "IAM policy language version."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
