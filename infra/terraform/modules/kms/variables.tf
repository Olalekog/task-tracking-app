variable "description" {
  description = "KMS key description."
  type        = string
}

variable "deletion_window_in_days" {
  description = "KMS key deletion window."
  type        = number
}

variable "enable_key_rotation" {
  description = "Enable KMS key rotation."
  type        = bool
}

variable "alias_name" {
  description = "KMS alias name."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
