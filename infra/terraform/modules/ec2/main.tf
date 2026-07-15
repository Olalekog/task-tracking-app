resource "aws_instance" "this" {
  for_each = var.instances

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                    = each.value.key_name
  iam_instance_profile        = each.value.iam_instance_profile
  user_data                   = each.value.user_data
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = each.value.root_volume_type
    encrypted   = each.value.encrypted
    kms_key_id  = each.value.kms_key_id
  }

  tags = merge(var.tags, { Name = each.key })
}
