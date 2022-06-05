data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "(cc-project) VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = var.availability_zones
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "(cc-project) Public Subnet (AZ${count.index + 1})"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.availability_zones
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "(cc-project) Private Subnet (AZ${count.index + 1})"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "(cc-project) Internet Gateway"
  }
}

resource "aws_eip" "ngw_elastic_ip" {
  count = var.availability_zones
  vpc   = true
  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "(cc-project) Elastic IPs for NAT Gateways"
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = var.availability_zones
  allocation_id = aws_eip.ngw_elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "(cc-project) NAT Gateway (AZ${count.index})"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "(cc-project) Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  count  = var.availability_zones
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name = "(cc-project) Private Route Table (AZ${count.index + 1})"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  count          = var.availability_zones
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  count          = var.availability_zones
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}
