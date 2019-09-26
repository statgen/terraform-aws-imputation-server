provider "aws" {
  region = "us-east-2"
}

module "imputation-vpc" {
  source = "./modules/imputation-vpc"

  name_prefix      = var.name_prefix
  ssh_ingress_cidr = var.ssh_ingress_cidr
}

resource "aws_s3_bucket" "log-bucket" {
  bucket = "imputation-example-network-traffic-logs"
  acl    = "private"
}

resource "aws_flow_log" "flow-log" {
  log_destination      = aws_s3_bucket.log-bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.imputation-vpc.vpc_id
}

# module "imputation-server" {
#   source = "./modules/imputation-server"

#   name_prefix = var.name_prefix
#   public_key  = var.emr_public_key

#   log_uri = "s3://aws-logs-536148068215-us-east-2/elasticmapreduce/"

#   master_instance_type = "m5.xlarge"
#   core_instance_type   = "m5.xlarge"
#   task_instance_type   = "m5.xlarge"

#   vpc_id                = module.imputation-vpc.vpc_id
#   ec2_subnet            = module.imputation-vpc.vpc_private_subnets[0]
#   master_security_group = module.imputation-vpc.emr_master_security_group_id
# }

# module "imputation-elb" {
#   source = "./modules/imputation-elb"

#   name_prefix = var.name_prefix
#   vpc_id      = module.imputation-vpc.vpc_id

#   lb_security_group = module.imputation-vpc.lb_security_group
#   lb_subnets        = module.imputation-vpc.vpc_public_subnets

#   master_node_id = module.imputation-server.master_node_id
# }

# # module "imputation-db" {
# #   source = "./modules/imputation-db"

# #   name_prefix = var.name_prefix

# #   database_subnet_ids        = module.imputation-vpc.vpc_database_subnets
# #   database_security_group_id = module.imputation-vpc.database_security_group_id

# #   db_password = var.database_password

# #   # Temp value for testing
# #   backup_retention_period = 0
# # }

module "imputation-bastion" {
  source = "./modules/imputation-bastion"

  name_prefix = var.name_prefix
  public_key  = var.bastion_public_key

  bastion_host_subnet_ids        = module.imputation-vpc.vpc_public_subnets
  bastion_host_security_group_id = module.imputation-vpc.bastion_host_security_group_id
}
