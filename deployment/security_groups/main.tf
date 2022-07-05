resource "aws_security_group" "external_load_balancer_sg" {
  name        = "external_load_balancer_security_group"
  description = "Allow HTTP inbound traffic to External ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "(${var.project_name}) Internet-facing Load Balancer SG"
  }
}

resource "aws_security_group" "internal_load_balancer_sg" {
  name        = "internal_load_balancer_security_group"
  description = "Allow HTTP inbound traffic to Internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = {
    Name = "(${var.project_name}) Internal Load Balancer SG"
  }
}

resource "aws_security_group" "frontend_host_sg" {
  name        = "frontend_host_security_group"
  description = "Allow HTTP inbound traffic to EC2 hosts from external ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from external_load_balancer_sg on port 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.external_load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "(${var.project_name}) Frontend EC2 host SG"
  }
}

resource "aws_security_group" "backend_host_sg" {
  name        = "backend_host_security_group"
  description = "Allow HTTP inbound traffic to EC2 hosts from internal ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from internal_load_balancer_sg on port 80"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "(${var.project_name}) Backend EC2 host SG"
  }
}
