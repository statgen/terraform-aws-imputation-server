# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across accounts"
  default     = "imputation-example"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which the cluster is deployed"
  default     = null
  type        = string
}

variable "lb_security_group" {
  description = "security group for ELB"
  default     = null
  type        = string
}

variable "lb_subnets" {
  description = "The subnet where the ELB will be deployed"
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "port" {
  description = "Port for load balancer to forward to"
  default     = "8082"
  type        = string
}

variable "environment" {
  description = "Value for environment tag"
  default     = "dev"
  type        = string
}
