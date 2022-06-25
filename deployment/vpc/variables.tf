variable "project_name" {
    description = "Prefix to use in resource names"
    type = string
} 

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks of public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
