# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
  type        = string
}

variable "public_key" {
  description = "RSA public key for AWS key pair"
  default     = null
  type        = string
}

variable "bastion_host_security_group_id" {
  description = "Security group for bastion host"
  default     = null
  type        = string
}

variable "bastion_host_subnet_ids" {
  description = "Subnet ids for bastion host"
  default     = []
  type        = list
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for bastion host"
  default     = "t2.micro"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size for bastion host in GB"
  default     = "64"
  type        = string
}

variable "environment" {
  description = "Value for environment tag"
  default     = "dev"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to attach to the bastion host"
  default     = null
  type        = string
}
