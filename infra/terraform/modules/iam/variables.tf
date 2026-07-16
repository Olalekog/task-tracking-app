variable "roles" {
  description = "IAM role definitions."
  type = map(object({
    assume_role_policy      = any
    create_instance_profile = optional(bool, false)
    description             = optional(string)
    force_detach_policies   = optional(bool, false)
    inline_policies         = optional(map(any), {})
    instance_profile_path   = optional(string, "/")
    managed_policy_arns     = optional(list(string), [])
    max_session_duration    = optional(number, 3600)
    path                    = optional(string, "/")
    permissions_boundary    = optional(string)
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
