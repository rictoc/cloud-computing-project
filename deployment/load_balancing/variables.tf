variable "project_name" {
    description = "Prefix to use in resource names"
    type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "public_subnets" {
  description = "Public subnets ids"
  type = list(string)
}

variable "private_subnets" {
  description = "Private subnets ids"
  type = list(string)
}

variable "external_load_balancer_sg" {
  description = "Security group for internet-facing load balancer"
  type = string
}

variable "internal_load_balancer_sg" {
  description = "Security group for internal load balancer"
  type = string
}