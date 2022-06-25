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
    target_group_arn = aws_lb_target_group.external_lb_default_tg.arn
  }
}

resource "aws_lb_target_group" "external_lb_default_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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
    target_group_arn = aws_lb_target_group.internal_lb_default_tg.arn
  }
}

resource "aws_lb_target_group" "internal_lb_default_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}