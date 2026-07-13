variable "bucket_name" {
  description = "S3 bucket name."
  type        = string
}

variable "force_destroy" {
  description = "Allow non-empty bucket deletion."
  type        = bool
}

variable "versioning_status" {
  description = "S3 bucket versioning status."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for S3 encryption."
  type        = string
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm."
  type        = string
}

variable "block_public_acls" {
  description = "Block public ACLs."
  type        = bool
}

variable "block_public_policy" {
  description = "Block public bucket policies."
  type        = bool
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs."
  type        = bool
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets."
  type        = bool
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
}
