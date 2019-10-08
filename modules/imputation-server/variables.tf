# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

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

variable "bootstrap_action" {
  description = "List of bootstrap actions that will be run before Hadoop is started on the cluster"
  default     = []
  type        = list(object({ name : string, path : string, args : list(string) }))
  # example:
  # bootstrap_action = [{
  #   name = "imputation-bootstrap"
  #   path = "s3://imputationserver-aws/bootstrap.sh"
  #   args = []
  # },]
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

variable "aws_kms_key_tags" {
  description = "Tags to be applied to the AWS KMS key"
  default     = {}
  type        = map(string)
}

variable "emr_iam_role_tags" {
  description = "Tags to be applied to the IAM Role for the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "ec2_iam_role_tags" {
  description = "Tags to be applied to the IAM Role for the EC2 instances in the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "ec2_autoscaling_role_tags" {
  description = "Tags to be applied to the EC2 autoscaling role for the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "emr_cluster_tags" {
  description = "Tags to be applied to the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "module_tags" {
  description = "Tags applied to all supported resources in module"
  default     = {}
  type        = map(string)
}
