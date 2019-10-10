# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}

# ----------------------------------------------------------------------------------------------------------------------
# FIND EMR MASTER NODE ID
# ----------------------------------------------------------------------------------------------------------------------

data "aws_instance" "master_node" {
  depends_on = [aws_emr_cluster.cluster]

  # Get EMR master instance for export
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
# CREATE AN EMPTY AWS KEY PAIR
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "emr_key_pair" {
  key_name   = "${var.name_prefix}-emr"
  public_key = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN AWS KMS KEY FOR EMR DISK ENCRYPTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kms_key" "emr_kms" {
  description             = "AWS KMS key for EMR data encryption"
  deletion_window_in_days = 30
  is_enabled              = true
  enable_key_rotation     = true

  tags = merge(
    var.aws_kms_key_tags,
    var.module_tags,
  )
}

resource "aws_kms_alias" "emr_kms" {
  name          = "alias/${var.name_prefix}-key-alias"
  target_key_id = aws_kms_key.emr_kms.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT EMR SERVICE ROLES PERMISSION TO USE KMS KEY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kms_grant" "ec2_kms_grant" {
  key_id            = aws_kms_key.emr_kms.arn
  grantee_principal = aws_iam_role.ec2.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext"]
}

resource "aws_kms_grant" "emr_kms_grant" {
  key_id            = aws_kms_key.emr_kms.arn
  grantee_principal = aws_iam_role.emr.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "CreateGrant", "RetireGrant"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE EMR SECURITY CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_emr_security_configuration" "emr_sec_config" {
  name_prefix = "${var.name_prefix}-"

  configuration = <<EOF
{
    "EncryptionConfiguration": {
        "AtRestEncryptionConfiguration": {
            "S3EncryptionConfiguration": {
                "EncryptionMode": "SSE-S3"
            },
            "LocalDiskEncryptionConfiguration": {
                "EncryptionKeyProviderType": "AwsKms",
                "AwsKmsKey": "${aws_kms_key.emr_kms.arn}",
                "EnableEbsEncryption": true
            }
        },
        "EnableInTransitEncryption": false,
        "EnableAtRestEncryption": true
    }
}
EOF
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

  tags = merge(
    var.emr_iam_role_tags,
    var.module_tags,
  )
}

resource "aws_iam_role_policy_attachment" "emr" {
  role       = aws_iam_role.emr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json

  tags = merge(
    var.ec2_iam_role_tags,
    var.module_tags,
  )
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2_autoscaling" {
  name               = "${var.name_prefix}-ec2-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.application_autoscaling.json

  tags = merge(
    var.ec2_autoscaling_role_tags,
    var.module_tags,
  )
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

  security_configuration = aws_emr_security_configuration.emr_sec_config.name

  ec2_attributes {
    key_name                          = aws_key_pair.emr_key_pair.key_name
    subnet_id                         = var.ec2_subnet
    additional_master_security_groups = var.master_security_group
    instance_profile                  = aws_iam_instance_profile.ec2.name
  }

  master_instance_group {
    instance_type = var.master_instance_type

    ebs_config {
      size                 = var.master_instance_ebs_size
      type                 = "gp2"
      volumes_per_instance = 1
    }
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = 3

    ebs_config {
      size                 = var.core_instance_ebs_size
      type                 = "gp2"
      volumes_per_instance = 1
    }


    autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": ${var.core_instance_count_min},
  "MaxCapacity": ${var.core_instance_count_max}
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

  tags = merge(
    var.emr_cluster_tags,
    var.module_tags,
  )

  dynamic "bootstrap_action" {
    for_each = var.bootstrap_action
    content {
      name = bootstrap_action.value.name
      path = bootstrap_action.value.path
      args = bootstrap_action.value.args
    }
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

  service_role     = aws_iam_role.emr.name
  autoscaling_role = aws_iam_role.ec2_autoscaling.name
}

resource "aws_emr_instance_group" "task" {
  name           = "${var.name_prefix}-instance-group"
  cluster_id     = aws_emr_cluster.cluster.id
  instance_count = 2
  instance_type  = var.task_instance_type

  bid_price = var.bid_price

  ebs_optimized = true

  ebs_config {
    size                 = var.task_instance_ebs_size
    type                 = "gp2"
    volumes_per_instance = 1
  }

  autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": ${var.task_instance_count_min},
  "MaxCapacity": ${var.task_instance_count_max}
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
