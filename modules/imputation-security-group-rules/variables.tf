variable "emr_security_group_id" {
  description = "The Security Group ID of the Elastic Map Reduce (EMR) master node"
  default     = null
  type        = string
}

variable "emr_slave_security_group_id" {
  description = "The Security Group ID of the Elastic Map Reduce (EMR) slave workers"
  default     = null
  type        = string
}

variable "lb_security_group_id" {
  description = "The Security Group ID of the Application Load Balancer (ALB)"
  default     = null
  type        = string
}
