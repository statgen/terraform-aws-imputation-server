# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
  type        = string
}

variable "database_subnet_ids" {
  description = "Subnet ids for database"
  default     = []
  type        = list
}

variable "database_security_group_id" {
  description = "Security group for database"
  default     = null
  type        = string
}

variable "db_password" {
  description = "Password for mySQL database"
  default     = null
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  description = "Value for environment tag"
  default     = "dev"
  type        = string
}

variable "mysql_engine_version" {
  description = "MySQL engine verison"
  default     = "8.0.15"
  type        = string
}

variable "db_instance_class" {
  description = "DB instance class type"
  default     = "db.t3.medium"
  type        = string
}

variable "db_storage" {
  description = "Amount of storage for database in GB"
  default     = "32"
  type        = string
}

variable "db_username" {
  description = "Username for database"
  default     = "imputationuser"
  type        = string
}

variable "db_port" {
  description = "Port for database connection"
  default     = "3306"
  type        = string
}

variable "maintenance_window" {
  description = "Maintenance window for DB upgrade performed by AWS"
  default     = "Mon:00:00-Mon:03:00"
  type        = string
}

variable "backup_window" {
  description = "Backup window for automatic DB backups"
  default     = "03:00-06:00"
  type        = string
}

variable "backup_retention_period" {
  description = "Number for days to keep backups"
  default     = "5"
  type        = string
}
