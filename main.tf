module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.56.0"

  container_name  = var.name
  container_image = local.ghost_image

  container_cpu                = var.container_cpu != null ? var.container_cpu : var.ecs_task_cpu
  container_memory             = var.container_memory != null ? var.container_memory : var.ecs_task_memory
  container_memory_reservation = var.container_memory_reservation

  port_mappings = [
    {
      containerPort = var.ghost_port
      hostPort      = var.ghost_port
      protocol      = "tcp"
    },
  ]

  mount_points = [
    {
      containerPath = "/var/lib/ghost/content"
      sourceVolume = "storage"
      readOnly = false
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.ghost.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }

  map_environment = {
    url = var.site_url
  }

  firelens_configuration = var.firelens_configuration

  environment = concat(
  local.container_definition_environment,
  var.custom_environment_variables,
  )

}

resource "aws_ecs_task_definition" "ghost" {
  family                   = var.name
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory

  container_definitions = jsonencode([module.container_definition.json_map_object])

  volume {
    name = "storage"

    efs_volume_configuration {
      file_system_id = var.file_system_id
      root_directory = "/"
      transit_encryption = var.efs_transit_encryption
      transit_encryption_port = var.efs_transit_encryption_port
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" "ghost" {
  name    = var.name
  cluster = var.cluster_id

  task_definition                    = aws_ecs_task_definition.ghost.arn
  desired_count                      = var.ecs_service_desired_count
  launch_type                        = var.ecs_fargate_spot ? null : "FARGATE"
  platform_version                   = var.ecs_service_platform_version
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent
  force_new_deployment               = var.ecs_service_force_new_deployment

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [module.ghost_sg.this_security_group_id]
    assign_public_ip = var.ecs_service_assign_public_ip
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.ghost_port
    target_group_arn = var.target_group_arn
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.ecs_fargate_spot ? [true] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  }

  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  propagate_tags          = var.propagate_tags

  tags = var.tags

}

resource "aws_cloudwatch_log_group" "ghost" {
  name              = var.name
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}


