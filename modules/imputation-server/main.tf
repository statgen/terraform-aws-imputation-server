# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AWS KEY PAIR FOR EMR MASTER NODE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "emr_key_pair" {
  key_name   = "${var.name_prefix}-emr"
  public_key = var.public_key
}

# ----------------------------------------------------------------------------------------------------------------------
# FIND EMR MASTER NODE ID
# ----------------------------------------------------------------------------------------------------------------------

data "aws_instance" "master_node" {
  depends_on = [aws_emr_cluster.cluster]

  # Get EMR master instance
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:aws:elasticmapreduce:instance-group-role"
    values = ["MASTER"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLES AND POLICIES TO SUPPORT EMR AUTOSCALING AND CONNECTIONS TO AWS SERVICES
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "assume_role_emr" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "application_autoscaling" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com", "elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "emr" {
  name               = "${var.name_prefix}-emr-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_emr.json
}

resource "aws_iam_role_policy_attachment" "emr" {
  role       = aws_iam_role.emr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2_autoscaling" {
  name               = "${var.name_prefix}-ec2-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.application_autoscaling.json
}

resource "aws_iam_role_policy_attachment" "ec2_autoscaling" {
  role       = aws_iam_role.ec2_autoscaling.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ELASTIC MAP REDUCE (EMR) CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_emr_cluster" "cluster" {
  name          = "${var.name_prefix}-cluster"
  release_label = var.emr_release_label
  applications  = ["Hadoop", "Ganglia"]

  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = true

  log_uri = var.log_uri

  ec2_attributes {
    key_name                          = aws_key_pair.emr_key_pair.key_name
    subnet_id                         = var.ec2_subnet
    additional_master_security_groups = var.master_security_group
    instance_profile                  = aws_iam_instance_profile.ec2.arn
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = 2

    ebs_config {
      size                 = var.core_instance_ebs_size
      type                 = "gp2"
      volumes_per_instance = 1
    }

    bid_price = var.bid_price

    autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": 2,
  "MaxCapacity": 6
},
"Rules": [
  {
    "Name": "ScaleOutMemoryPercentage",
    "Description": "Scale out if YARNMemoryAvailablePercentage is less than 15",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 1,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "LESS_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 15.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }

  bootstrap_action {
    path = var.bootstrap_path
    name = "imputation"
  }

  configurations_json = <<EOF
  [{
  "Classification": "mapred-site",
  "Properties": {
    "mapreduce.map.memory.mb": "15000",
    "mapreduce.map.java.opts": "-Xmx12000m",
    "mapreduce.task.timeout": "10368000000",
    "mapreduce.map.speculative": "false",
    "mapreduce.reduce.speculative": "false"
  }
}]
EOF

  service_role     = aws_iam_role.emr.arn
  autoscaling_role = aws_iam_role.ec2_autoscaling.arn
}

