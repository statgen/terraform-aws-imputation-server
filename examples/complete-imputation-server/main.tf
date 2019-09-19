provider "aws" {
  region = "us-east-1"
}

module "imputation-vpc" {
  source = "../../modules/imputation-vpc"

  name_prefix = "csg-imputation"
}

module "imputation-server" {
  source = "../../modules/imputation-server"

  name_prefix = "csg-imputation"
  public_key  = ""

  vpc_id                = module.imputation-vpc.vpc_id
  ec2_subnet            = module.imputation-vpc.vpc_private_subnets[0]
  master_security_group = module.imputation-vpc.emr_master_security_group_id
}

module "imputation-elb" {
  source = "../../modules/imputation-elb"

  name_prefix = "csg-imputation"
  vpc_id      = module.imputation-vpc.vpc_id

  lb_security_group = module.imputation-vpc.lb_security_group
  lb_subnets        = module.imputation-vpc.vpc_public_subnets
}

module "imputation-db" {
  source = "../../modules/imputation-db"

  name_prefix = "csg-imputation"

  database_subnet_ids        = module.imputation-vpc.vpc_database_subnets
  database_security_group_id = module.imputation-vpc.database_security_group_id

  db_password = "Dontusethisinproduction!"
}
