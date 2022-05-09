output "cloudwatch_high_memory_utilization"{
    value = aws_cloudwatch_metric_alarm.memory-high.alarm_name
}

output "cloudwatch_low_memory_utilization"{
    value = aws_cloudwatch_metric_alarm.memory-low.alarm_name
}

output "cloudwatch_alarm_actions"{
    value = aws_cloudwatch_metric_alarm.memory-low.alarm_actions 
}

output "auto_scaling_arn"{
    value = aws_autoscaling_group.protagona-ASG.arn
}

output "auto_scaling_group_name"{
    value = aws_autoscaling_group.protagona-ASG.name
}

output "alb-type"{
    value = aws_lb.protagona-ALB.load_balancer_type
}

output "target_group_name"{
    value = aws_lb_target_group.protagona-TargetGroup.name
}

output "target_group_arn"{
    value = aws_lb_target_group.protagona-TargetGroup.arn
}

output "default_vpc_id"{
    value = module.vpc.default_vpc_id
}

output "igw_id"{
    value = module.vpc.igw_id
}

output "natgateway_public_ips"{
    value = module.vpc.nat_public_ips
}

output "private_subnets"{
    value = module.vpc.private_subnets
}

output "public_subnets"{
    value = module.vpc.public_subnets
}

output "vpc_id"{
    value = module.vpc.vpc_id
}

