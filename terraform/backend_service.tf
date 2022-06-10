resource "aws_launch_configuration" "backend_launch_configuration" {
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.backend_ec2_host_sg.id]
  iam_instance_profile = "LabInstanceProfile"
  enable_monitoring    = true
  user_data            = <<-EOT
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
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cc-project/backend

    docker run \
    -p 80:80 \
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cc-project/backend
  EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                      = "backend_hosts_asg"
  vpc_zone_identifier       = aws_subnet.private_subnet[*].id
  launch_configuration      = aws_launch_configuration.backend_launch_configuration.name
  target_group_arns         = [aws_lb_target_group.backend_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  max_size                  = 4
  min_size                  = 2

  tag {
    key                 = "Name"
    value               = "(cc-project) Backend ASG instance"
    propagate_at_launch = true
  }
}
