variable "repositories" {
  description = "ECR repositories to create."
  type = map(object({
    image_tag_mutability           = string
    scan_on_push                   = bool
    encryption_type                = string
    kms_key_arn                    = string
    force_delete                   = bool
    lifecycle_policy_max_images    = number
    lifecycle_policy_tag_status    = string
    lifecycle_policy_count_type    = string
    lifecycle_policy_action_type   = string
    lifecycle_policy_description   = string
    lifecycle_policy_rule_priority = number
  }))
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
