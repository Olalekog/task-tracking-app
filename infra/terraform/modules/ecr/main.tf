resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.kms_key_arn
  }

  tags = merge(var.tags, { Name = each.key })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.repositories

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = each.value.lifecycle_policy_rule_priority
        description  = each.value.lifecycle_policy_description
        selection = {
          tagStatus   = each.value.lifecycle_policy_tag_status
          countType   = each.value.lifecycle_policy_count_type
          countNumber = each.value.lifecycle_policy_max_images
        }
        action = {
          type = each.value.lifecycle_policy_action_type
        }
      }
    ]
  })
}
