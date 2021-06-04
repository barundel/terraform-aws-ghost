module "ghost_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.17.0"

  name        = var.name
  vpc_id      = var.vpc_id
  description = "Security group with open port for Ghost (${var.ghost_port}) from ALB, egress ports are all world open"

  ingress_cidr_blocks      = [data.aws_vpc.vpc.cidr_block]
  ingress_rules            = ["all-all"]

  ingress_with_source_security_group_id = [
    {
      from_port                = var.ghost_port
      to_port                  = var.ghost_port
      protocol                 = "tcp"
      description              = "Ghost Container"
      source_security_group_id = var.alb_sg_id
    },
    {
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      description              = "EFS Access"
      source_security_group_id = var.efs_sg
    },
  ]

  egress_rules = ["all-all"]

  tags = var.tags
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}