output "emr_role_arn" {
  description = "The ARN of the EMR role"
  value       = aws_iam_role.emr.arn
}

output "emr_role_name" {
  description = "The name of the EMR role"
  value       = aws_iam_role.emr.name
}

output "emr_role_unique_id" {
  description = "The stable and unique string identifying the EMR role"
  value       = aws_iam_role.emr.unique_id
}

output "ec2_role_arn" {
  description = "The ARN of the EC2 role"
  value       = aws_iam_role.ec2.arn
}

output "ec2_role_name" {
  description = "The name of the EC2 role"
  value       = aws_iam_role.ec2.name
}

output "ec2_role_unique_id" {
  description = "The stable and unique string identifying the EC2 role"
  value       = aws_iam_role.emr.unique_id
}

output "ec2_autoscaling_role_arn" {
  description = "The ARN of the EC2 autoscaling role"
  value       = aws_iam_role.ec2_autoscaling.arn
}

output "ec2_autoscaling_role_name" {
  description = "The name of the EC2 autoscaling role"
  value       = aws_iam_role.ec2_autoscaling.name
}

output "ec2_autoscaling_role_unique_id" {
  description = "The stable and unique string identifying the EC2 autoscaling role"
  value       = aws_iam_role.ec2_autoscaling.unique_id
}

output "ec2_instance_profile_id" {
  description = "The ID of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.id
}

output "ec2_instance_profile_arn" {
  description = "The ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.name
}
