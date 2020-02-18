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
  public_key = var.public_key
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
    var.tags,
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
  key_id = aws_kms_key.emr_kms.arn
  # grantee_principal = aws_iam_role.ec2.arn
  grantee_principal = var.ec2_role_arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext"]
}

resource "aws_kms_grant" "emr_kms_grant" {
  key_id = aws_kms_key.emr_kms.arn
  # grantee_principal = aws_iam_role.emr.arn
  grantee_principal = var.emr_role_arn
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

  custom_ami_id = var.custom_ami_id

  ec2_attributes {
    key_name                          = aws_key_pair.emr_key_pair.key_name
    subnet_id                         = var.ec2_subnet
    emr_managed_master_security_group = var.emr_managed_master_security_group
    emr_managed_slave_security_group  = var.emr_managed_slave_security_group
    service_access_security_group     = var.service_access_security_group

    # instance_profile = aws_iam_instance_profile.ec2.name
    instance_profile = var.ec2_instance_profile_name
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
    "Name": "HDFSUtilization",
    "Description": "Scale out if HDFSUtilization is more than 70%",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 1,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "HDFSUtilization",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 75.0,
        "Unit": "PERCENT"
      }
    }
  },
  {
    "Name": "HDFSUtilizationScaleIn",
    "Description": "Scale in if HDFSUtilization is less than 50%",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -1,
        "CoolDown": 1500
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "LESS_THAN",
        "EvaluationPeriods": 5,
        "MetricName": "HDFSUtilization",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 1500,
        "Statistic": "AVERAGE",
        "Threshold": 50.0,
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
    var.tags,
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
    "mapreduce.map.memory.mb": "32000",
    "mapreduce.map.java.opts": "-Xmx25600m",
    "mapreduce.map.cpu.vcores": "4",
    "mapreduce.task.timeout": "10368000000",
    "mapreduce.map.speculative": "false",
    "mapreduce.reduce.speculative": "false",
    "yarn.scheduler.maximum-allocation-cores": "128",
    "yarn.scheduler.maximum-allocation-mb": "64000",
    "yarn.scheduler.capacity.maximum-am-resource-percent": "1.0",
    "yarn.app.mapreduce.am.resource.memory-mb": "1280",
    "yarn.app.mapreduce.am.command-opts": "-Xmx1024m",
    "yarn.app.mapreduce.am.resource.vcores": "1"
  }
}]
EOF

  # service_role     = aws_iam_role.emr.name
  service_role = var.emr_role_name
  # autoscaling_role = aws_iam_role.ec2_autoscaling.name
  autoscaling_role = var.ec2_autoscaling_role_name
}

resource "aws_emr_instance_group" "task" {
  name           = "${var.name_prefix}-instance-group"
  cluster_id     = aws_emr_cluster.cluster.id
  instance_count = var.task_instance_count_min
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
  },
  {
    "Name": "ScaleInMemoryPercentage",
    "Description": "Scale in if YARNMemoryAvailablePercentage is greater than 30",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -1,
        "CoolDown": 600
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 600,
        "Statistic": "AVERAGE",
        "Threshold": 30.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
}
