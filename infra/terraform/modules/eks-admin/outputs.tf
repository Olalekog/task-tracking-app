output "instance_id" {
  description = "SSM-managed EKS administration instance ID."
  value       = aws_instance.this.id
}

output "security_group_id" {
  description = "Administration instance security group ID."
  value       = aws_security_group.this.id
}

output "ssm_document_name" {
  description = "SSM document used to install kubectl and Helm."
  value       = aws_ssm_document.install_tools.name
}
