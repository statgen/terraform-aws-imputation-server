output "vpc_azs" {
  value       = module.vpc.azs
  description = "A list of availability zones specified as argument to this module"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The id of the vpc"
}

output "vpc_database_subnets" {
  value       = module.vpc.database_subnets
  description = "List of ids of database subnets"
}

output "vpc_public_subnets" {
  value       = module.vpc.public_subnets
  description = "List of ids of public subnets"
}

output "vpc_private_subnets" {
  value       = module.vpc.private_subnets
  description = "List of ids of private subnets"
}

output "lb_security_group" {
  value       = module.lb_sg.this_security_group_id
  description = "The ID of the security group"
}

output "database_security_group_id" {
  value       = module.database_sg.this_security_group_id
  description = "The ID of the security group"
}

output "bastion_host_security_group_id" {
  value       = module.bastion_host_sg.this_security_group_id
  description = "The ID of the security group"
}

output "emr_master_security_group_id" {
  value       = module.emr_master_sg.this_security_group_id
  description = "The ID of the security group"
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
  description = "The ID of the default security group"
}
