module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.5.0"

  identifier = "${var.name_prefix}-db"

  engine            = "mysql"
  engine_version    = var.mysql_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_storage
  storage_encrypted = true

  name     = "imputationdb"
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  create_db_subnet_group = true
  subnet_ids             = var.database_subnet_ids

  vpc_security_group_ids = [var.database_security_group_id]

  major_engine_version = "8.0"
  family               = "mysql8.0"

  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window

  backup_retention_period = var.backup_retention_period

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
