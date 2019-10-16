# ----------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP RULES THAT CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF THE EXAMPLE EMR CLUSTER
# !! WARNING !! These rules are only an example and should not be used in a secure production environment.
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# EMR SECURITY GROUP RULES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "emr_ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow SSH to EMR master node from all. This should be restricted in a production instance"

  security_group_id = var.emr_security_group_id
}

resource "aws_security_group_rule" "emr_imputation_ingress" {
  type                     = "ingress"
  from_port                = 8082
  to_port                  = 8082
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group_id

  description = "Allow ingress HTTP traffic on port 8082 from Application Load Balancer Security Group"

  security_group_id = var.emr_security_group_id
}

resource "aws_security_group_rule" "emr_all_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all egress traffic"

  security_group_id = var.emr_security_group_id
}

resource "aws_security_group_rule" "emr_slave_all_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all egress traffic"

  security_group_id = var.emr_slave_security_group_id
}

# ----------------------------------------------------------------------------------------------------------------------
# LB SECURITY GROUP RULES
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "lb_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow ingress HTTP traffic on port 80 from all"

  security_group_id = var.lb_security_group_id
}

resource "aws_security_group_rule" "lb_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow ingress HTTPS traffic on port 443 from all"

  security_group_id = var.lb_security_group_id
}

resource "aws_security_group_rule" "lb_http_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.emr_security_group_id

  description = "Allow egress HTTP traffic on port 80 to EMR cluster security group"

  security_group_id = var.lb_security_group_id
}

resource "aws_security_group_rule" "lb_https_egress" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.emr_security_group_id

  description = "Allow egress HTTPS traffic on port 443 to EMR cluster security group"

  security_group_id = var.lb_security_group_id
}

resource "aws_security_group_rule" "lb_imputation_egress" {
  type                     = "egress"
  from_port                = 8082
  to_port                  = 8082
  protocol                 = "tcp"
  source_security_group_id = var.emr_security_group_id

  description = "Allow egress HTTP traffic on port 8082 to EMR cluster security group"

  security_group_id = var.lb_security_group_id
}

resource "aws_security_group_rule" "lb_all_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all egress traffic"

  security_group_id = var.lb_security_group_id
}
