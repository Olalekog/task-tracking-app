#checkov:skip=CKV2_AWS_5:This reusable module returns the security group ID for attachment by calling modules.
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for index, rule in var.ingress_rules : index => rule }

  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
}

resource "aws_security_group_rule" "egress" {
  for_each = { for index, rule in var.egress_rules : index => rule }

  type                     = "egress"
  security_group_id        = aws_security_group.this.id
  description              = each.value.description
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
}
