output "key_pair_name" {
  description = "The EC2 Key Pair name for the bastion host"
  value       = aws_key_pair.bastion_key_pair.key_name
}

output "public_key" {
  description = "The public key for the bastion host"
  value       = aws_key_pair.bastion_key_pair.public_key
  sensitive   = true
}

output "public_ip" {
  description = "The public Elastic IP created for the bastion host"
  value       = aws_eip.this.public_ip
}

output "public_dns" {
  description = "The public DNS associated with the Elastic IP address"
  value       = aws_eip.this.public_dns
}

output "availability_zone" {
  description = "The availability zone of the bastion host"
  value       = element(module.bastion_host.availability_zone, 0)
}

output "id" {
  description = "The instance ID of the bastion host"
  value       = element(module.bastion_host.id, 0)
}

output "primary_network_interface_id" {
  description = "The ID of the primary network interface"
  value       = element(module.bastion_host.primary_network_interface_id, 0)
}

output "subnet_id" {
  description = "The ID of the VPC subnet of the bastion host"
  value       = element(module.bastion_host.subnet_id, 0)
}

output "vpc_security_group_ids" {
  description = "The associated security groups of the bastion host"
  value       = module.bastion_host.vpc_security_group_ids
}
