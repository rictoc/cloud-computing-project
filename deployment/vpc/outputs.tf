output "id" {
  value = aws_vpc.vpc.id
}

output "cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  value = aws_subnet.private_subnet[*].id
}

output "internet_gateway" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateways" {
  value = aws_nat_gateway.ngw[*].id
}
