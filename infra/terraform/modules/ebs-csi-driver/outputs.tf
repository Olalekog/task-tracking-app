output "iam_role_arn" {
  description = "IAM role ARN used by the EBS CSI driver controller service account."
  value       = aws_iam_role.this.arn
}

output "addon_arn" {
  description = "ARN of the aws-ebs-csi-driver EKS addon."
  value       = aws_eks_addon.this.arn
}
