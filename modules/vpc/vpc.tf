# Create a VPC
resource "aws_vpc" "infrasample" {
  instance_tenancy = "default"
  cidr_block       = var.vpc_cidr
  tags             = var.vpc_tags
}

resource "aws_internet_gateway" "infrasampleIGW" {
  vpc_id = aws_vpc.infrasample.id
  tags = {
    Name    = "infrasampleIGW"
    Project = "infrasample health"
  }
}

resource "aws_eip" "infrasampleNatGatewayEIP1" {
  tags = {
    Name    = "infrasampleNatGatewayEIP1"
    Project = "infrasample health"
  }
}

resource "aws_nat_gateway" "infrasampleNatGateway1" {
  allocation_id = aws_eip.infrasampleNatGatewayEIP1.id
  subnet_id     = aws_subnet.infrasamplePublicSubnet1.id
  tags = {
    Name    = "infrasampleNatGateway1"
    Project = "infrasample health"
  }
}

resource "aws_subnet" "infrasamplePublicSubnet1" {
  vpc_id            = aws_vpc.infrasample.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "infrasamplePublicSubnet1"
    Project = "infrasample health"
  }
}

resource "aws_eip" "infrasampleNatGatewayEIP2" {
  tags = {
    Name    = "infrasampleNatGatewayEIP2"
    Project = "infrasample health"
  }
}

resource "aws_nat_gateway" "infrasampleNatGateway2" {
  allocation_id = aws_eip.infrasampleNatGatewayEIP2.id
  subnet_id     = aws_subnet.infrasamplePublicSubnet1.id
  tags = {
    Name    = "infrasampleNatGateway2"
    Project = "infrasample health"
  }
}

resource "aws_subnet" "infrasamplePublicSubnet2" {
  vpc_id            = aws_vpc.infrasample.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "infrasamplePublicSubnet2"
    Project = "infrasample health"
  }
}

resource "aws_subnet" "infrasamplePrivateSubnet1" {
  vpc_id            = aws_vpc.infrasample.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "infrasamplePrivateSubnet1"
    Project = "infrasample health"
  }
}

resource "aws_subnet" "infrasamplePrivateSubnet2" {
  vpc_id            = aws_vpc.infrasample.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "infrasamplePrivateSubnet2"
    Project = "infrasample health"
  }
}

resource "aws_route_table" "infrasamplePublicRT" {
  vpc_id = aws_vpc.infrasample.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infrasampleIGW.id
  }
  tags = {
    name    = "infrasamplePublicRT"
    Project = "infrasample health"
  }
}

resource "aws_route_table" "infrasamplePrivateRT" {
  vpc_id = aws_vpc.infrasample.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.infrasampleNatGateway1.id
  }
  tags = {
    name    = "infrasamplePrivateRT"
    Project = "infrasample health"
  }
}

resource "aws_route_table_association" "infrasamplePublicRTassociation1" {
  subnet_id      = aws_subnet.infrasamplePublicSubnet1.id
  route_table_id = aws_route_table.infrasamplePublicRT.id
}

resource "aws_route_table_association" "infrasamplePublicRTassociation2" {
  subnet_id      = aws_subnet.infrasamplePublicSubnet2.id
  route_table_id = aws_route_table.infrasamplePublicRT.id
}

# TODO - (Playlsit IAC on AWS #3 at 19:34)