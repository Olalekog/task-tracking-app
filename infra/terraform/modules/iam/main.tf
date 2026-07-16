locals {
  managed_policy_attachments = merge(concat([
    for role_name, role in var.roles : {
      for index, policy_arn in try(role.managed_policy_arns, []) :
      "${role_name}-${index}" => {
        role_name  = role_name
        policy_arn = policy_arn
      }
    }
  ], [{}])...)

  inline_policies = merge(concat([
    for role_name, role in var.roles : {
      for policy_name, policy_document in try(role.inline_policies, {}) :
      "${role_name}-${policy_name}" => {
        role_name       = role_name
        policy_name     = policy_name
        policy_document = policy_document
      }
    }
  ], [{}])...)

  instance_profiles = {
    for role_name, role in var.roles :
    role_name => role
    if try(role.create_instance_profile, false)
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name = each.key

  path        = try(each.value.path, "/")
  description = try(each.value.description, null)
  assume_role_policy = jsonencode(merge(
    { Version = var.policy_version },
    each.value.assume_role_policy
  ))
  max_session_duration  = try(each.value.max_session_duration, 3600)
  permissions_boundary  = try(each.value.permissions_boundary, null)
  force_detach_policies = try(each.value.force_detach_policies, false)

  tags = merge(var.tags, {
    Name = each.key
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "this" {
  for_each = local.inline_policies

  name = each.value.policy_name
  role = aws_iam_role.this[each.value.role_name].name

  policy = jsonencode(
    merge(
      { Version = var.policy_version },
      each.value.policy_document
    )
  )
}

resource "aws_iam_instance_profile" "this" {
  for_each = local.instance_profiles

  name = each.key
  path = try(each.value.instance_profile_path, "/")
  role = aws_iam_role.this[each.key].name

  tags = merge(var.tags, {
    Name = each.key
  })
}
