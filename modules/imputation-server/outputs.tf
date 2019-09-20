output "master_node_id" {
  description = "EMR master node ID"
  value       = data.aws_instance.master_node.id
}
