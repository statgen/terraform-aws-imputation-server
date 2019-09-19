# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE A VPC
# ----------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  name = "${var.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnets   = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
  database_subnets = ["10.0.96.0/24", "10.0.97.0/24", "10.0.98.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_s3_endpoint = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  create_database_subnet_group = false

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create security groups
# ---------------------------------------------------------------------------------------------------------------------

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name        = "${var.name_prefix}-web-server"
  description = "Security group for frontend web-server with HTTP(S) ports open"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Inbound allow 80 TCP from all"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Inbound allow 443 TCP from all"
    },
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.emr_master_sg.this_security_group_id
      description              = "Outbound allow 80 TCP to EMR master node(s)"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.emr_master_sg.this_security_group_id
      description              = "Outbound allow 443 TCP to EMR master node(s)"
    },
    {
      from_port                = 8082
      to_port                  = 8082
      protocol                 = 6
      source_security_group_id = module.emr_master_sg.this_security_group_id
      description              = "Outbound allow 443 TCP to EMR master node(s)"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Outbound allow all"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name        = "${var.name_prefix}-database"
  description = "Security group for backend databse server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.emr_master_sg.this_security_group_id
      description              = "Inbound allow 3306 TCP from EMR master node(s)"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "bastion_host_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name        = "${var.name_prefix}-bastion-host"
  description = "Security group for bastion hosts"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.ssh_ingress_cidr
      description = "Inbound allow 22 TCP from Umich CIDR ranges"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr        = "0.0.0.0/0"
      description = "Egress allow all to all"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

module "emr_master_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.1.0"

  name        = "${var.name_prefix}-emr-master"
  description = "Security group for EMR master node(s)"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.web_server_sg.this_security_group_id
      description              = "Inbound allow 80 TCP from web server"
    },
    {
      from_port                = 8082
      to_port                  = 8082
      protocol                 = 6
      source_security_group_id = module.web_server_sg.this_security_group_id
      description              = "Inbound allow 8082 TCP from web server"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.web_server_sg.this_security_group_id
      description              = "Inbound allow 443 TCP from web server"
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_host_sg.this_security_group_id
      description              = "Inbound allow 22 TCP from bastion hosts"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr        = "0.0.0.0/0"
      description = "Egress allow all to all"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
