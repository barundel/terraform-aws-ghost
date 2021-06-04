data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = compact(distinct(concat(["ecs-tasks.amazonaws.com"], var.trusted_principals)))
    }

    dynamic "principals" {
      for_each = length(var.trusted_entities) > 0 ? [true] : []

      content {
        type        = "AWS"
        identifiers = var.trusted_entities
      }
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name                 = "${var.name}-ecs_task_execution"
  assume_role_policy   = data.aws_iam_policy_document.ecs_tasks.json
  permissions_boundary = var.permissions_boundary

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = length(var.policies_arn)

  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = element(var.policies_arn, count.index)
}