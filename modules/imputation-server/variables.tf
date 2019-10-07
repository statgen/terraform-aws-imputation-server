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
  description = "RSA public key for AWS key pair used to access cluster"
  default     = null
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which the cluster is deployed"
  default     = null
  type        = string
}

variable "ec2_subnet" {
  description = "The subnet to place EC2 instances in"
  default     = null
  type        = string
}

variable "master_security_group" {
  description = "Additional security group needed for load balancer communication"
  default     = null
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "bootstrap_action" {
  description = "List of bootstrap actions that will be run before Hadoop is started on the cluster"
  default = [{
    name = "imputation-bootstrap"
    path = "s3://imputationserver-aws/bootstrap.sh"
  }]
  type = list
}

variable "emr_release_label" {
  description = "EMR release to use when creating cluser"
  default     = "emr-5.26.0"
  type        = string
}

variable "log_uri" {
  description = "S3 bucket to write the log files of the job flow logs. If not provided logs are not created"
  default     = null
  type        = string
}

variable "termination_protection" {
  default = false
  type    = bool
}

variable "master_instance_type" {
  description = "Instance type for EMR master node"
  default     = "r5.4xlarge"
  type        = string
}

variable "master_instance_ebs_size" {
  description = "Size for EBS disk on master instance in GB"
  default     = "2048"
  type        = string
}

variable "core_instance_type" {
  description = "Core instance type for EMR"
  default     = "r5.xlarge"
  type        = string
}

variable "core_instance_ebs_size" {
  description = "Size for EBS disk on core instances in GB"
  default     = "2048"
  type        = string
}

variable "core_instance_count_min" {
  description = "Min capacity for core instance ASG"
  default     = 3
}

variable "core_instance_count_max" {
  description = "Max capacity for core instance ASG"
  default     = 6
}

variable "task_instance_count_min" {
  description = "Min capacity for task instance ASG"
  default     = 3
}

variable "task_instance_count_max" {
  description = "Max capacity for task instance ASG"
  default     = 15
}

variable "task_instance_type" {
  description = "Task instance type for EMR"
  default     = "r5.24xlarge"
  type        = string
}

variable "task_instance_ebs_size" {
  description = "Size for EBS disk on task instances in GB"
  default     = "2048"
  type        = string
}

variable "bid_price" {
  description = "Bid price for spot instances in EMR cluster. Default is higher than on-demand price to avoid interuptions"
  default     = "10.00"
  type        = string
}

variable "environment" {
  description = "Value for environment tag"
  default     = "dev"
  type        = string
}

