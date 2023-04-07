# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "ec2_autoscaling_role_name" {
  description = "The name of the role for EC2 instance autoscaling"
  default     = null
  type        = string
}

variable "ec2_subnet" {
  description = "The subnet to place EC2 instances in"
  default     = null
  type        = string
}

variable "ec2_role_arn" {
  description = "The ARN of the role for the EC2 instances in the EMR cluster"
  default     = null
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "The name of the instance profile for the EC2 instances in the EMR cluster"
  default     = null
  type        = string
}

variable "emr_managed_master_security_group" {
  description = "Additional security group needed for load balancer communication"
  default     = null
  type        = string
}

variable "emr_role_arn" {
  description = "The ARN of the role for the EMR cluster"
  default     = null
  type        = string
}

variable "emr_role_name" {
  description = "The name of the role for the EMR cluster"
  default     = null
  type        = string
}

variable "emr_managed_slave_security_group" {
  description = "Additional security group needed for load balancer communication"
  default     = null
  type        = string
}

variable "service_access_security_group" {
  description = "EC2 service access security group for EMR cluster in private subnet"
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

variable "public_key" {
  description = "RSA public key for AWS key pair used to access cluster"
  default     = null
  type        = string
}

variable "alert_sns_arn" {
  description = "The ARN of an SNS topic used to deliver notification or system health alerts"
  default     = null
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_kms_key_tags" {
  description = "Tags to be applied to the AWS KMS key"
  default     = {}
  type        = map(string)
}

variable "bid_price" {
  description = "Bid price for spot instances in EMR cluster. Default is higher than on-demand price to avoid interruptions"
  default     = "10.00"
  type        = string
}

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

variable "core_instance_count_max" {
  description = "Max capacity for core instance ASG"
  default     = 20
  type        = number
}

variable "core_instance_count_min" {
  description = "Min capacity for core instance ASG"
  default     = 10
  type        = number
}

variable "core_instance_ebs_size" {
  description = "Size for EBS disk on core instances in GB"
  default     = "2048"
  type        = string
}

variable "core_instance_type" {
  description = "Core instance type for EMR"
  default     = "r5.2xlarge"
  type        = string
}

variable "custom_ami_id" {
  description = "A custom AMI for the cluster"
  default     = null
  type        = string
}

variable "ec2_autoscaling_role_tags" {
  description = "Tags to be applied to the EC2 autoscaling role for the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "ec2_iam_role_tags" {
  description = "Tags to be applied to the IAM Role for the EC2 instances in the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "emr_cluster_tags" {
  description = "Tags to be applied to the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "emr_iam_role_tags" {
  description = "Tags to be applied to the IAM Role for the EMR cluster"
  default     = {}
  type        = map(string)
}

variable "emr_release_label" {
  description = "EMR release to use when creating cluster"
  default     = "emr-5.28.0"
  type        = string
}

variable "log_uri" {
  description = "S3 bucket to write the log files of the job flow logs. If not provided logs are not created"
  default     = null
  type        = string
}

variable "master_instance_ebs_size" {
  description = "Size for EBS disk on master instance in GB"
  default     = "4096"
  type        = string
}

variable "master_instance_type" {
  description = "Instance type for EMR master node"
  default     = "r5.4xlarge"
  type        = string
}

variable "tags" {
  description = "Tags applied to all supported resources in module"
  default     = {}
  type        = map(string)
}

# After a blue/green deploy, we usually want to kill the old dead env, but keep the new one (which has usually scaled up)
#  Use this variable during deploys to avoid accidentally down-sizing the production cluster to minimum settings
variable "task_instance_ondemand_count_current" {
  description = "Current size of the worker pool (on demand)- preserve this many when terraform runs, if more than min"
  default     = 0
  type        = number
}

# On demand instances are a fallback for spot, and should have fewer instances.
variable "task_instance_ondemand_count_max" {
  description = "Max capacity for task instance ASG (on demand)"
  default     = 15
  type        = number
}

variable "task_instance_ondemand_count_min" {
  description = "Min capacity for task instance ASG (on demand)"
  default     = 1
  type        = number
}

variable "task_instance_spot_count_current" {
  description = "Current size of the worker pool (spot)- preserve this many when terraform runs, if more than min"
  default     = 0
  type        = number
}


# Spot instances are the preferred worker type and should usually have higher min/max values
variable "task_instance_spot_count_max" {
  description = "Max capacity for task instance ASG (spot)"
  default     = 50
  type        = number
}

variable "task_instance_spot_count_min" {
  description = "Min capacity for task instance ASG (spot)"
  default     = 3
  type        = number
}

variable "task_instance_ebs_size" {
  description = "Size for EBS disk on task instances in GB"
  default     = "2048"
  type        = string
}

variable "task_instance_type" {
  description = "Task instance type for EMR"
  default     = "r5.24xlarge"
  type        = string
}

variable "termination_protection" {
  default = false
  type    = bool
}
