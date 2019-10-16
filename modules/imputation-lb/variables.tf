# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "certificate_arn" {
  description = "The ARN of the default SSL server certificate"
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

variable "master_node_id" {
  description = "EMR master node ID"
  default     = null
  type        = string
}

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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_https" {
  description = "If set to true, ALB will use HTTPS with provided certificate ARN"
  default     = true
  type        = bool
}

variable "lb_tags" {
  description = "Tags applied to AWS Application Load Balancer"
  default     = {}
  type        = map(string)
}

variable "lb_target_group_tags" {
  description = "Tags applied to the Load Balancer target group"
  default     = {}
  type        = map(string)
}

variable "port" {
  description = "Port for load balancer to forward to"
  default     = "8082"
  type        = string
}

variable "ssl_policy" {
  description = "The name of the SSL Policy for the listener"
  default     = "ELBSecurityPolicy-2016-08"
  type        = string
}

variable "tags" {
  description = "Tags applied to all supported resources in module"
  default     = {}
  type        = map(string)
}
