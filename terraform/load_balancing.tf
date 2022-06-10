resource "aws_lb" "external_load_balancer" {
  name               = "public-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.external_load_balancer_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
}

resource "aws_lb_target_group" "frontend_target_group" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.external_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

resource "aws_lb" "internal_load_balancer" {
  name               = "private-load-balancer"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.internal_load_balancer_sg.id]
  subnets            = aws_subnet.private_subnet[*].id
}

resource "aws_lb_target_group" "backend_target_group" {
  name     = "backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.internal_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }
}
