# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
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

variable "ssh_ingress_cidr" {
  description = "CIDR range to allow for SSH to bastion host"
  default     = "0.0.0.0/0"
  type        = string
}
