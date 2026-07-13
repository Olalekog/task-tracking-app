output "instance_ids" {
  description = "EC2 instance IDs."
  value       = { for name, instance in aws_instance.this : name => instance.id }
}

output "public_ips" {
  description = "EC2 public IPs by instance name."
  value       = { for name, instance in aws_instance.this : name => instance.public_ip }
}

output "private_ips" {
  description = "EC2 private IPs by instance name."
  value       = { for name, instance in aws_instance.this : name => instance.private_ip }
}
