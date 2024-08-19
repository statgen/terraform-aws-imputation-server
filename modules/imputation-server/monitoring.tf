/// This alarm is a useful idea in theory, but it's noisy, and doesn't operate on the timescales we need
//     It also can't account for the dual-queue design of cloudgene (the "active" vs "queued" feature): if 15 jobs
//      are exporting, then even though there are 100 jobs in queue, hadoop won't be sent work, and will signal "all clear"
//     No amount of alarm cleverness can compensate for a webapp that hides information from the system, which makes it hard to fix alarm just from the AWS side.
// We'll keep the alarm defined and tracking metrics, in case it aids future capacity planning. But it won't send alerts.
resource "aws_cloudwatch_metric_alarm" "cluster_needs_resources" {
  # Warn if the system is unable to scale enough, after several hours of trying. Resolved by:
  #  a) add spot capacity (if we're blitzed with lots of jobs),
  #  b) add on demand capacity (if we're backlogged because spot capacity is unavailable).
  # NOTE: if the on demand group is enlarged outside of TF, this alarm won't be updated automatically
  alarm_name        = "${var.name_prefix}-cluster-needs-resources"
  alarm_description = "Warn when cluster cannot scale to meet demand. May indicate inability to get spot instances, or generally high load requiring more workers in task group."

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  # Our workloads are bursty, and will often clear a small backlog (1-2 days). Notify when we are maxed for longer.
  datapoints_to_alarm = 24
  evaluation_periods  = 24

  actions_enabled = false # Don't send alerts- see notes.

  # Notify when the alarm changes state- for good or bad
  alarm_actions = [var.alert_sns_arn]
  ok_actions    = [var.alert_sns_arn]

  metric_query {
    id = "nodes"

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
    id = "memfree"

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

    expression = "(nodes >= ${var.task_instance_ondemand_count_max}) AND (memfree <= 25)"
  }
}