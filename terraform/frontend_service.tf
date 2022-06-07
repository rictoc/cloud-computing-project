resource "aws_launch_configuration" "frontend_launch_configuration" {
  # name                 = "frontend_host_launch_config"
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.frontend_ec2_host_sg.id]
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
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cc-project/frontend_service

    docker run \
    -p 80:80 \
    -e PREDICTION_SERVICE_HOSTNAME=${aws_lb.internal_load_balancer.dns_name} \
    -e PREDICTION_SERVICE_PORT=80 \
    ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/cc-project/frontend_service
  EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "frontend_asg" {
  name                 = "frontend_hosts_asg"
  vpc_zone_identifier  = aws_subnet.private_subnet[*].id
  launch_configuration = aws_launch_configuration.frontend_launch_configuration.name
  target_group_arns    = [aws_lb_target_group.frontend_target_group.arn]
  health_check_type    = "ELB"
  max_size             = 4
  min_size             = 2
}