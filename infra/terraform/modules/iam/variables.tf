variable "roles" {
  description = "IAM role definitions."
  type        = any
}

variable "policy_version" {
  description = "IAM policy language version."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
