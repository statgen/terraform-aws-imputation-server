variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
  type        = string
}

variable "emr_public_key" {
  description = "RSA public key used for AWS key pair for EMR master node"
  default     = ""
  type        = string
}

variable "bastion_public_key" {
  description = "RSA public key used for AWS key pair for bastion host"
  default     = ""
  type        = string
}

variable "database_password" {
  description = "Password for imputation database"
  default     = ""
  type        = string
}

variable "ssh_ingress_cidr" {

}
