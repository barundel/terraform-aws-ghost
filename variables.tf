locals {
  ghost_image = var.ghost_image == "" ? "ghost:${var.ghost_version}" : var.ghost_image

  container_definition_environment = [
    {
      name  = "TEST"
      value = "EXAMPLE"
    },
  ]
}

variable "custom_environment_variables" {
  description = "List of additional environment variables the container will use (list should contain maps with `name` and `value`)"
  type = list(object(
  {
    name  = string
    value = string
  }
  ))
  default = []
}

variable "target_group_arn" {
  description = "The ARN of the target group associated with your ALB"
  type = string
}

variable "create_route53_record" {
  description = "If to create Route53 record for Ghost"
  type        = bool
  default     = false
}

variable "ecs_service_desired_count" {
  default = 1
  description = "The desired capacity for your service"
}

variable "ecs_service_platform_version" {
  description = "The platform version on which to run your service"
  type        = string
  default     = "LATEST"
}

variable "ghost_image" {
  description = "Docker image to run Ghost with. If not specified, official Ghost image will be used"
  type        = string
  default     = ""
}

variable "ghost_version" {
  description = "Verion of Ghost to run. If not specified latest will be used"
  type        = string
  default     = "latest"
}

variable "ecs_service_deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 50
}

variable "private_subnet_ids" {
  description = "Private subnet ids"
  type = list(string)
}

variable "permissions_boundary" {
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
  type        = string
  default     = null
}

variable "policies_arn" {
  description = "A list of the ARN of the policies you want to apply"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "trusted_entities" {
  description = "A list of  users or roles, that can assume the task role"
  type        = list(string)
  default     = []
}

variable "ecs_service_assign_public_ip" {
  description = "Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)"
  type        = bool
  default     = false
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION"
  type        = string
  default     = null
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = false
}

variable "trusted_principals" {
  description = "A list of principals, in addition to ecs-tasks.amazonaws.com, that can assume the task role"
  type        = list(string)
  default     = []
}

variable "ecs_fargate_spot" {
  description = "Whether to run ECS Fargate Spot or not"
  type        = bool
  default     = false
}

variable "ecs_service_force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. myimage:latest)"
  type        = bool
  default     = false
}

variable "ecs_task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 512
}

variable "ecs_task_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 256
}

variable "tags" {
  type = map(string)
  default = {}
  description = "Map of tags to assign to resources"
}

variable "name" {
  default = "ghost"
  description = "Name of the service, default is Ghost"
  type = string
}

variable "cloudwatch_retention_days" {
  default = 30
  description = "How many days to keep the containers cloudwatch logs"
  type = number
}

variable "cluster_id" {
  description = "The ID of the ECS cluster"
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC you want to use"
  type = string
}

variable "ghost_port" {
  description = "Local port Ghost should be running on. Default value is most likely fine"
  type        = number
  default     = 2368
}

variable "alb_sg_id" {
  description = "The ID of your ALB security group"
}

variable "container_cpu" {
  description = "The number of cpu units used by the ghost container. If not specified ecs_task_cpu will be used"
  type        = number
  default     = null
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the ghost container. If not specified ecs_task_memory will be used"
  type        = number
  default     = null
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container"
  type        = number
  default     = 128
}

# https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html
variable "firelens_configuration" {
  description = "The FireLens configuration for the container. This is used to specify and configure a log router for container logs. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_FirelensConfiguration.html"
  type = object({
    type    = string
    options = map(string)
  })
  default = null
}

variable "file_system_id" {
  description = "File System ID of your EFS instance"
  type = string
}

variable "efs_transit_encryption" {
  default = "ENABLED"
  type = string
  description = "(Optional) Whether or not to enable encryption for Amazon EFS data in transit between the Amazon ECS host and the Amazon EFS server. Transit encryption must be enabled if Amazon EFS IAM authorization is used. Valid values: ENABLED, DISABLED. If this parameter is omitted, the default value of DISABLED is used."
}

variable "efs_transit_encryption_port" {
  default = "2999"
  type = string
  description = "(Optional) Port to use for transit encryption. If you do not specify a transit encryption port, it will use the port selection strategy that the Amazon EFS mount helper uses."
}

variable "efs_sg" {
  description = "SG ID of the SG Assigned to the EFS mount point."
  type = string
}

variable "site_url" {
  description = "Enter the URL that is used to access your publication. If using a subpath, enter the full path, https://example.com/blog/. If using SSL, always enter the URL with https://."
  type = string
}

aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:103089792444:certificate/00809796-c638-4eff-9c96-61d1963495d9 --profile coop-dev --region us-east-1