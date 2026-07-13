variable "roles" {
  description = "IAM roles to create."
  type = map(object({
    assume_role_policy      = any
    managed_policy_arns     = optional(list(string), [])
    inline_policies         = optional(map(any), {})
    path                    = optional(string, "/")
    description             = optional(string, null)
    max_session_duration    = optional(number, 3600)
    permissions_boundary    = optional(string, null)
    force_detach_policies   = optional(bool, true)
    create_instance_profile = optional(bool, false)
    instance_profile_path   = optional(string, "/")
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
