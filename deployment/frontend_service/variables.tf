variable "project_name" {
  description = "Prefix to use in resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnets ids"
  type        = list(string)
}

variable "target_group" {
  description = "Load balancer target group for EC2 hosts"
}

variable "security_group" {
  description = "Security group for EC2 hosts"
  type        = string
}

variable "image_name" {
  description = "Name of service image on ECR"
}

variable "ami_id" {
  description = "AMI for EC2 hosts"
  type        = string
}

variable "instance_type" {
  description = "Type of EC2 instances"
  type        = string
}

variable "backend_hostname" {
  description = "Backend service service"
  type        = string
}