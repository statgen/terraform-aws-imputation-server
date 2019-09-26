output "lb_id" {
  description = "The ID of the load balancer (same as ARN)"
  value       = aws_lb.imputation_lb.id
}

output "lb_arn" {
  description = "The ARN of the load balancer (same as ID)"
  value       = aws_lb.imputation_lb.arn
}

output "lb_arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_lb.imputation_lb.arn_suffix
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.imputation_lb.dns_name
}

output "lb_name" {
  description = "The name of the load balancer"
  value       = aws_lb.imputation_lb.name
}
