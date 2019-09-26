# ---------------------------------------------------------------------------------------------------------------------
# VPC OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_azs" {
  value       = module.vpc.azs
  description = "A list of availability zones specified as argument to this module"
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = module.vpc.database_network_acl_id
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.vpc.database_route_table_ids
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = module.vpc.database_subnet_arns
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}

output "database_subnets" {
  description = "List of ids of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "List of CIDR blocks of database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "name" {
  description = "The name of the VPC"
  value       = module.vpc.name
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateways"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "List of public Elastic IPs create for AWS NAT Gateways"
  value       = module.vpc.nat_public_ips
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.vpc.private_network_acl_id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "private_subnets" {
  description = "List of ids of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = module.vpc.public_network_acl_id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "public_subnets" {
  description = "List of ids of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_enable_dns_hostnames" {
  description = "Wheather or not the VPC has DNS hostname support"
  value       = module.vpc.vpc_enable_dns_hostnames
}

output "vpc_endpoint_s3_id" {
  description = "The ID of the VPC endpoint for S3"
  value       = module.vpc.vpc_endpoint_s3_id
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The id of the vpc"
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with the VPC"
  value       = module.vpc.vpc_main_route_table_id
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------

output "lb_security_group_description" {
  description = "The description of the load balancer security group"
  value       = module.lb_sg.this_security_group_description
}

output "lb_security_group_id" {
  description = "The ID of the load balancer security group"
  value       = module.lb_sg.this_security_group_id
}

output "lb_security_group_name" {
  description = "The name of the load balancer security group"
  value       = module.lb_sg.this_security_group_name
}

output "lb_security_group_owner_id" {
  description = "The owner ID of the load balancer security group"
  value       = module.lb_sg.this_security_group_owner_id
}

output "lb_security_group_vpc_id" {
  description = "The VPC ID of the load balancer security group"
  value       = module.lb_sg.this_security_group_vpc_id
}

output "database_security_group_description" {
  description = "The description of the database security group"
  value       = module.database_sg.this_security_group_description
}

output "database_security_group_id" {
  description = "The ID of the database security group"
  value       = module.database_sg.this_security_group_id
}

output "database_security_group_name" {
  description = "The name of the database security group"
  value       = module.database_sg.this_security_group_name
}

output "database_security_group_owner_id" {
  description = "The owner ID of the database security group"
  value       = module.database_sg.this_security_group_owner_id
}

output "database_security_group_vpc_id" {
  description = "The VPC ID of the database security group"
  value       = module.database_sg.this_security_group_vpc_id
}

output "bastion_host_security_group_description" {
  description = "The description of the bastion host security group"
  value       = module.bastion_host_sg.this_security_group_description
}

output "bastion_host_security_group_id" {
  description = "The ID of the bastion host security group"
  value       = module.bastion_host_sg.this_security_group_id
}

output "bastion_host_security_group_name" {
  description = "The name of the bastion host security group"
  value       = module.bastion_host_sg.this_security_group_name
}

output "bastion_host_security_group_owner_id" {
  description = "The owner ID of the bastion host security group"
  value       = module.bastion_host_sg.this_security_group_owner_id
}

output "bastion_host_security_group_vpc_id" {
  description = "The VPC ID of the bastion host security group"
  value       = module.bastion_host_sg.this_security_group_vpc_id
}

output "emr_master_security_group_description" {
  description = "The description of the emr master security group"
  value       = module.emr_master_sg.this_security_group_description
}

output "emr_master_security_group_id" {
  description = "The ID of the emr master security group"
  value       = module.emr_master_sg.this_security_group_id
}

output "emr_master_security_group_name" {
  description = "The name of the emr master security group"
  value       = module.emr_master_sg.this_security_group_name
}

output "emr_master_security_group_owner_id" {
  description = "The owner ID of the emr master security group"
  value       = module.emr_master_sg.this_security_group_owner_id
}

output "emr_master_security_group_vpc_id" {
  description = "The VPC ID of the emr master security group"
  value       = module.emr_master_sg.this_security_group_vpc_id
}
