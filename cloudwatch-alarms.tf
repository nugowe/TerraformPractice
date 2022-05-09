resource "aws_autoscaling_policy" "agents-scale-up" {
    name = "agents-scale-up"
    depends_on                = [aws_autoscaling_group.protagona-ASG]
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.protagona-ASG.name}"
}

resource "aws_autoscaling_policy" "agents-scale-down" {
    name = "agents-scale-down"
    depends_on                = [aws_autoscaling_group.protagona-ASG]
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.protagona-ASG.name}"
}

resource "aws_cloudwatch_metric_alarm" "memory-high" {
    depends_on                = [aws_autoscaling_group.protagona-ASG, aws_autoscaling_policy.agents-scale-down, aws_autoscaling_policy.agents-scale-up ]
    alarm_name = "mem-util-high-agents"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "80"
    alarm_description = "This metric monitors ec2 memory for high utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-up.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.protagona-ASG.name}"
    }
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
    depends_on                = [aws_autoscaling_group.protagona-ASG, aws_autoscaling_policy.agents-scale-down, aws_autoscaling_policy.agents-scale-up ]
    alarm_name = "mem-util-low-agents"

    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "MemoryUtilization"
    namespace = "System/Linux"
    period = "300"
    statistic = "Average"
    threshold = "40"
    alarm_description = "This metric monitors ec2 memory for low utilization on agent hosts"
    alarm_actions = [
        "${aws_autoscaling_policy.agents-scale-down.arn}"
    ]
    dimensions = {
        AutoScalingGroupName = "${aws_autoscaling_group.protagona-ASG.name}"
    }
}