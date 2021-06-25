# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY AN IMPUTATION SERVER, A LOAD BALANCER, AND VPC IN AWS
# This is an example of how to use the imputation-server and imputation-lb modules to deploy an imputation server
# instance in AWS with an Application Load Balancer in front of it in a new VPC.
#
# !! WARNING !! This is only an example and should not be used for a production instance. Further hardening such as TLS,
# security settings, private subnets, custom public key pairs, and management infrastructure should be in place with this
# deployment.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_region" "current" {}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE VPC
# ----------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.1.0"

  name = "imputation-example-vpc"
  cidr = "10.120.0.0/16"

  azs            = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
  public_subnets = ["10.120.48.0/20", "10.120.64.0/20"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform = "true"
    Project   = "imputation-example"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE SECURITY GROUPS
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lb_sg" {
  name        = "imputation-example-lb-sg"
  description = "Security group for the front end Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = { Name = "imputation-example-lb" }
}

resource "aws_security_group" "emr_sg" {
  name        = "imputation-example-emr-sg"
  description = "Security group for the Elastic Map Reduce master node"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  tags = { Name = "imputation-example-emr" }
}

resource "aws_security_group" "emr_slave_sg" {
  name        = "imputation-example-emr-slave-sg"
  description = "Security group for the Elastic Map Reduce master node"
  vpc_id      = module.vpc.vpc_id

  revoke_rules_on_delete = true

  tags = { Name = "imputation-example-emr-slave" }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE SECURITY GROUP RULES
# ----------------------------------------------------------------------------------------------------------------------

module "imputation-security-group-rules" {
  source = "./modules/imputation-security-group-rules"

  emr_security_group_id       = aws_security_group.emr_sg.id
  emr_slave_security_group_id = aws_security_group.emr_slave_sg.id
  lb_security_group_id        = aws_security_group.lb_sg.id
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE IMPUTATION SERVER IAM ROLES
# ----------------------------------------------------------------------------------------------------------------------

module "imputation-iam" {
  source = "./modules/imputation-iam"

  name_prefix = "imputation-example"

  tags = {
    Terraform = "true"
    Project   = "imputation-example"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE IMPUTATION SERVER EMR CLUSTER
# ----------------------------------------------------------------------------------------------------------------------

locals {
  ec2_subnet = element(module.vpc.public_subnets, 0)
}

module "imputation-server" {
  source = "./modules/imputation-server"

  name_prefix = "imputation-example"

  vpc_id                            = module.vpc.vpc_id
  ec2_subnet                        = local.ec2_subnet
  ec2_role_arn                      = module.imputation-iam.ec2_role_arn
  emr_role_name                     = module.imputation-iam.emr_role_name
  emr_role_arn                      = module.imputation-iam.emr_role_arn
  ec2_instance_profile_name         = module.imputation-iam.ec2_instance_profile_name
  ec2_autoscaling_role_name         = module.imputation-iam.ec2_autoscaling_role_name
  emr_managed_master_security_group = aws_security_group.emr_sg.id
  emr_managed_slave_security_group  = aws_security_group.emr_slave_sg.id

  public_key = var.public_key

  bootstrap_action = [{
    name = "imputation-example-bootstrap"
    path = var.bootstrap_script_path
    args = var.bootstrap_script_args
  }]

  tags = {
    Terraform = "true"
    Project   = "imputation-example"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# CREATE EXAMPLE IMPUTATION LOAD BALANCER
# ----------------------------------------------------------------------------------------------------------------------

module "imputation-lb" {
  source = "./modules/imputation-lb"

  name_prefix = "imputation-example"

  vpc_id = module.vpc.vpc_id

  lb_security_group = aws_security_group.lb_sg.id
  lb_subnets        = module.vpc.public_subnets

  master_node_id = module.imputation-server.master_node_id

  # HTTPS should be used in production environment
  # For this example we do not have a valid TLS cert created so we choose false
  enable_https = false

  tags = {
    Terraform = "true"
    Project   = "imputation-example"
  }
}
