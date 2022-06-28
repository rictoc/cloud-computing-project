# internet-facing load balancer 
resource "aws_lb" "external_load_balancer" {
  name               = "${var.project_name}-public-load-balancer"
  load_balancer_type = "application"
  security_groups    = [var.external_load_balancer_sg]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "external_lb_http_listener" {
  load_balancer_arn = aws_lb.external_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_hosts_tg.arn
  }
}

resource "aws_lb_target_group" "frontend_hosts_tg" {
  name     = "${var.project_name}-frontend-hosts-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type = "lb_cookie"
  }
}

# load balancer for internal communication
resource "aws_lb" "internal_load_balancer" {
  name               = "${var.project_name}-private-load-balancer"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [var.internal_load_balancer_sg]
  subnets            = var.private_subnets
}

resource "aws_lb_listener" "internal_lb_http_listener" {
  load_balancer_arn = aws_lb.internal_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_hosts_tg.arn
  }
}

resource "aws_lb_target_group" "backend_hosts_tg" {
  name     = "${var.project_name}-backend-hosts-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}