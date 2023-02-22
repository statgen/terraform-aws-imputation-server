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
  filter {
    name   = "private-dns-name"
    values = [aws_emr_cluster.cluster.master_public_dns]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN EMPTY AWS KEY PAIR
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_key_pair" "emr_key_pair" {
  key_name_prefix = "${var.name_prefix}-emr"
  public_key      = var.public_key
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
  name_prefix   = "alias/${var.name_prefix}-key-alias"
  target_key_id = aws_kms_key.emr_kms.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT EMR SERVICE ROLES PERMISSION TO USE KMS KEY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_kms_grant" "ec2_kms_grant" {
  key_id            = aws_kms_key.emr_kms.arn
  grantee_principal = var.ec2_role_arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext"]
}

resource "aws_kms_grant" "emr_kms_grant" {
  key_id            = aws_kms_key.emr_kms.arn
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
  applications  = ["Hadoop"]

  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = true

  log_uri = var.log_uri

  security_configuration = aws_emr_security_configuration.emr_sec_config.name

  custom_ami_id = var.custom_ami_id

  ebs_root_volume_size = 100

  ec2_attributes {
    key_name                          = aws_key_pair.emr_key_pair.key_name
    subnet_id                         = var.ec2_subnet
    emr_managed_master_security_group = var.emr_managed_master_security_group
    emr_managed_slave_security_group  = var.emr_managed_slave_security_group
    service_access_security_group     = var.service_access_security_group

    instance_profile = var.ec2_instance_profile_name
  }

  master_instance_group {
    instance_type = var.master_instance_type
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = 10

    autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": ${var.core_instance_count_min},
  "MaxCapacity": ${var.core_instance_count_max}
},
"Rules": [
  {
    "Name": "HDFSUtilizationScaleOut",
    "Description": "Scale out if HDFSUtilization is more than 75%",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 2,
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
      "mapreduce.map.memory.mb": "40000",
      "mapreduce.map.java.opts": "-Xmx32000m",
      "mapreduce.map.cpu.vcores": "4",
      "mapreduce.task.timeout": "10368000000",
      "mapreduce.map.speculative": "false",
      "mapreduce.reduce.speculative": "false",
      "mapreduce.am.max-attempts": "200",
      "yarn.app.mapreduce.am.resource.mb": "5120",
      "yarn.app.mapreduce.am.command-opts": "-Xmx4096m",
      "yarn.app.mapreduce.am.resource.vcores": "2"
    }
  },
  {
    "Classification": "yarn-site",
    "Properties": {
      "yarn.resourcemanager.am.max-attempts": "200",
      "yarn.node-labels.enabled": "true"
    }
  },
  {
    "Classification": "capacity-scheduler",
    "Properties": {
      "yarn.scheduler.maximum-allocation-cores": "128",
      "yarn.scheduler.maximum-allocation-mb": "40000",
      "yarn.scheduler.capacity.maximum-am-resource-percent": "1.0"
    }
  }]
EOF

  service_role     = var.emr_role_name
  autoscaling_role = var.ec2_autoscaling_role_name
}

resource "aws_emr_instance_group" "task" {
  # EMR workers using spot instances. This is the preferred type due to cost, and has more favorable scaling options.
  name       = "${var.name_prefix}-instance-group"
  cluster_id = aws_emr_cluster.cluster.id
  #  instance_count = var.task_instance_spot_count_min
  instance_type = var.task_instance_type

  bid_price = var.bid_price

  configurations_json = <<EOF
  [{
    "Classification": "yarn-site",
    "Properties": {
      "yarn.nodemanager.node-labels.provider": "config",
      "yarn.nodemanager.node-labels.provider.configured-node-partition": "TASK"
    }
  }]
  EOF

  autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": ${var.task_instance_spot_count_min},
  "MaxCapacity": ${var.task_instance_spot_count_max}
},
"Rules": [
  {
    "Name": "ScaleOutMemoryPercentage",
    "Description": "Scale out if YARNMemoryAvailablePercentage is less than 25",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": 2,
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
        "Threshold": 25.0,
        "Unit": "PERCENT"
      }
    }
  },
  {
    "Name": "ScaleInMemoryPercentage",
    "Description": "Scale in if YARNMemoryAvailablePercentage is greater than 50",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -2,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 50.0,
        "Unit": "PERCENT"
      }
    }
  },
  {
    "Name": "ScaleInMemoryPercentageAggressive",
    "Description": "Scale in if YARNMemoryAvailablePercentage is greater than 75",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -3,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 75.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
}

resource "aws_emr_instance_group" "task_ondemand" {
  # EMR workers using on demand ("immediate availability") instances. This will scale slower, b/c we prefer spot.
  #  This group exists to ensure continued operation iff spot instances are unavailable for an extended period of time.
  name       = "${var.name_prefix}-instance-group-ondemand"
  cluster_id = aws_emr_cluster.cluster.id
  # instance_count = var.task_instance_ondemand_count_min
  instance_type = var.task_instance_type

  configurations_json = <<EOF
  [{
    "Classification": "yarn-site",
    "Properties": {
      "yarn.nodemanager.node-labels.provider": "config",
      "yarn.nodemanager.node-labels.provider.configured-node-partition": "TASK"
    }
  }]
  EOF

  autoscaling_policy = <<EOF
{
"Constraints": {
  "MinCapacity": ${var.task_instance_ondemand_count_min},
  "MaxCapacity": ${var.task_instance_ondemand_count_max}
},
"Rules": [
  {
    "Name": "ScaleOutMemoryPercentage",
    "Description": "Scale out if YARNMemoryAvailablePercentage is less than 25",
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
        "EvaluationPeriods": 5,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 25.0,
        "Unit": "PERCENT"
      }
    }
  },
  {
    "Name": "ScaleInMemoryPercentageAggressive",
    "Description": "Scale in if YARNMemoryAvailablePercentage is greater than 75",
    "Action": {
      "SimpleScalingPolicyConfiguration": {
        "AdjustmentType": "CHANGE_IN_CAPACITY",
        "ScalingAdjustment": -3,
        "CoolDown": 300
      }
    },
    "Trigger": {
      "CloudWatchAlarmDefinition": {
        "ComparisonOperator": "GREATER_THAN",
        "EvaluationPeriods": 1,
        "MetricName": "YARNMemoryAvailablePercentage",
        "Namespace": "AWS/ElasticMapReduce",
        "Period": 300,
        "Statistic": "AVERAGE",
        "Threshold": 75.0,
        "Unit": "PERCENT"
      }
    }
  }
]
}
EOF
}
