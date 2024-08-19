output "emr_applications" {
  description = "The applications installed on this cluster"
  value       = aws_emr_cluster.cluster.applications
}

output "emr_bootstrap_action" {
  description = "A list of bootstrap actions that will be run before Hadoop is started on the cluster"
  value       = aws_emr_cluster.cluster.bootstrap_action
}

output "emr_configurations" {
  description = "The list of Configurations supplied to the EMR cluster"
  value       = aws_emr_cluster.cluster.configurations
}

output "emr_cluster_id" {
  description = "The ID of the EMR Cluster"
  value       = aws_emr_cluster.cluster.id
}

output "emr_cluster_name" {
  description = "The name of the EMR Cluster"
  value       = aws_emr_cluster.cluster.name
}

output "emr_cluster_release_label" {
  description = "The release label for the EMR release"
  value       = aws_emr_cluster.cluster.release_label
}

output "emr_ec2_attributes" {
  description = "Provides information about the EC2 instances in the cluster"
  value       = aws_emr_cluster.cluster.ec2_attributes
}

output "emr_instance_group_id" {
  description = "The EMR (spot) Instance Group ID, if any"
  value       = length(aws_emr_instance_group.task) > 0 ? one(aws_emr_instance_group.task).id : null
}

output "emr_instance_group_name" {
  description = "The name of the (spot) Instance Group, if any"
  value       = length(aws_emr_instance_group.task) > 0 ? one(aws_emr_instance_group.task).name : null
}

output "emr_instance_group_running_instance_count" {
  description = "The number of (spot) instances currently running in this instance group, if any"
  value       = length(aws_emr_instance_group.task) > 0 ? one(aws_emr_instance_group.task).running_instance_count : 0
}

output "emr_instance_group_ondemand_id" {
  description = "The EMR (on demand) Instance ID"
  value       = aws_emr_instance_group.task_ondemand.id
}

output "emr_instance_group_ondemand_name" {
  description = "The name of the (on demand) Instance Group"
  value       = aws_emr_instance_group.task_ondemand.name
}

output "emr_instance_group_ondemand_running_instance_count" {
  description = "The number of (on demand) instances currently running in this instance group"
  value       = aws_emr_instance_group.task_ondemand.running_instance_count
}

output "emr_log_uri" {
  description = "The path to the Amazon S3 location where logs for this cluster are stored"
  value       = aws_emr_cluster.cluster.log_uri
}

output "emr_master_public_dns" {
  description = "The public DNS name of the master EC2 instance"
  value       = aws_emr_cluster.cluster.master_public_dns
}

output "emr_service_role" {
  description = "The IAM role that will be assumed by the Amazon EMR service to access AWS resources"
  value       = aws_emr_cluster.cluster.service_role
}

output "kms_key_alias" {
  description = "The ARN of the alias"
  value       = aws_kms_alias.emr_kms.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for EMR encryption"
  value       = aws_kms_key.emr_kms.arn
}

output "kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.emr_kms.key_id
}

output "master_node_id" {
  description = "EMR master node ID"
  value       = data.aws_instance.master_node.id
}

output "security_configuration" {
  description = "The JSON formatted Security Configuration"
  value       = aws_emr_security_configuration.emr_sec_config.configuration
}

output "security_configuration_id" {
  description = "The ID of the EMR Security Configuration"
  value       = aws_emr_security_configuration.emr_sec_config.id
}

output "security_configuration_name" {
  description = "The name of the EMR Security Configuration"
  value       = aws_emr_security_configuration.emr_sec_config.name
}
