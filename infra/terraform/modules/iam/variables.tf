variable "roles" {
  description = "Map of IAM roles to create."

  type = map(object({
    path                    = optional(string, "/")
    description             = optional(string, "")
    max_session_duration    = optional(number, 3600)
    permissions_boundary    = optional(string)
    force_detach_policies   = optional(bool, false)
    create_instance_profile = optional(bool, false)
    instance_profile_path   = optional(string, "/")

    assume_role_policy = object({
      Statement = list(any)
    })

    managed_policy_arns = optional(list(string), [])
    inline_policies     = optional(map(any), {})
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
