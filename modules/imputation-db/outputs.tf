output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.this_db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.db.this_db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = module.db.this_db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = module.db.this_db_instance_endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the RDS instance"
  value       = module.db.this_db_instance_hosted_zone_id
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = module.db.this_db_instance_id
}

output "db_instance_name" {
  description = "The database name"
  value       = module.db.this_db_instance_name
}

output "db_instance_port" {
  description = "The database port"
  value       = module.db.this_db_instance_port
}

output "db_instance_resource_id" {
  description = "The RDS resouce ID of this instance"
  value       = module.db.this_db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = module.db.this_db_instance_status
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.db.this_db_instance_username
}
