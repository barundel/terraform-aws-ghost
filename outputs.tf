output "ghost_sg" {
  value = module.ghost_sg.this_security_group_id
  description = "Security group ID assigned to ghost container"
}