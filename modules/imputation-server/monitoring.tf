resource "aws_cloudwatch_metric_alarm" "cluster_needs_resources" {
  # Warn if the system is unable to scale enough, after several hours of trying. Resolved by:
  #  a) add spot capacity (if we're blitzed with lots of jobs),
  #  b) add on demand capacity (if we're backlogged because spot capacity is unavailable).
  alarm_name          = "${var.name_prefix}-cluster-needs-resources"
  alarm_description   = "Track whether spot instance capacity has become highly constrained. Will notify admins that on demand capacity should be allocated to restore service."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  evaluation_periods  = 2

  actions_enabled = true

  # Notify when the alarm changes state- for good or bad
  alarm_actions = [var.alert_sns_arn]
  ok_actions    = [var.alert_sns_arn]

  metric_query {
    id = "m1"

    return_data = false

    metric {
      metric_name = "TaskNodesRunning"
      namespace   = "AWS/ElasticMapReduce"
      period      = 3600
      stat        = "Maximum"

      dimensions = {
        JobFlowId = aws_emr_cluster.cluster.id
      }
    }
  }

  metric_query {
    id = "m2"

    return_data = false

    metric {
      metric_name = "YARNMemoryAvailablePercentage"
      namespace   = "AWS/ElasticMapReduce"
      period      = 3600
      stat        = "Average"

      dimensions = {
        "JobFlowId" = aws_emr_cluster.cluster.id
      }
    }
  }

  metric_query {
    # "If on demand pool is maxed out, AND system is resource-constrained after trying to autoscale for a while"
    id    = "e1"
    label = "ClusterNeedsResources"

    return_data = true

    expression = "(m1 >= ${var.task_instance_ondemand_count_max}) AND (m2 <= 25)"
  }
}