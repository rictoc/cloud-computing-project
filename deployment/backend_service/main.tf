data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_autoscaling_group" "backend_asg" {
  name                      = "backend-service-asg"
  vpc_zone_identifier       = var.subnets
  launch_configuration      = aws_launch_configuration.backend_launch_configuration.name
  target_group_arns         = [var.target_group]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_elb_capacity          = 1
  max_size                  = 4
  min_size                  = 2
  enabled_metrics = ["GroupInServiceCapacity"]

  tag {
    key                 = "Name"
    value               = "(${var.project_name}) Backend ASG instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "backend_as_policy" {
  name                   = "backend-autoscaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_launch_configuration" "backend_launch_configuration" {
  image_id             = var.ami_id
  instance_type        = var.instance_type
  security_groups      = [var.security_group]
  iam_instance_profile = "LabInstanceProfile"
  enable_monitoring    = true

  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker
    service docker start
    usermod -a -G docker ec2-user
    chkconfig docker on

    aws ecr get-login-password \
    --region ${data.aws_region.current.name} | \
    docker login \
    --username AWS \
    --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com

    docker pull \
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.image_name}

    docker run \
    -p 80:80 \
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.image_name}
  EOT

  lifecycle {
    create_before_destroy = true
  }
}