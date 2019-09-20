# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN APPLICATION LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "imputation_lb" {
  name               = "imputation-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group]
  subnets            = var.lb_subnets

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "imputation_lb_tg" {
  name     = "imputation-lb-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    path    = "/index.html"
  }
}

resource "aws_lb_target_group_attachment" "imputation_lb_target" {
  target_group_arn = aws_lb_target_group.imputation_lb_tg.arn
  target_id        = var.master_node_id
  port             = var.port
}

resource "aws_lb_listener" "imputation_http_fwd" {
  load_balancer_arn = aws_lb.imputation_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.imputation_lb_tg.arn
  }
}
