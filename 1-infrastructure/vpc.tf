### Provider
provider "aws" {
  region = var.region
}

### Defining Backend for state file
terraform {
  backend "s3" {
    region = "eu-west-1"
  }
}

### Creating vpc network
resource "aws_vpc" "production_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Production-VPC"
  }
}

### Creating Public Subnet
resource "aws_subnet" "public-subnet-1" {
  cidr_block         = var.public_subnet_1_cidr
  vpc_id             = aws_vpc.production_vpc.id
  availability_zone  = "eu-west-1a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Public-Subnet-2"
  }
}

resource "aws_subnet" "public-subnet-3" {
  cidr_block        = var.public_subnet_3_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "eu-west-1c"

  tags = {
    Name = "Public-Subnet-3"
  }
}

### Creating Private Subnet
resource "aws_subnet" "private-subnet-1" {
  cidr_block = var.private_subnet_1_cidr
  vpc_id = aws_vpc.production_vpc.id
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  cidr_block = var.private_subnet_2_cidr
  vpc_id = aws_vpc.production_vpc.id
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

resource "aws_subnet" "private-subnet-3" {
  cidr_block = var.private_subnet_3_cidr
  vpc_id = aws_vpc.production_vpc.id
  availability_zone = "eu-west-1c"

  tags = {
    Name = "Private-Subnet-3"
  }
}

### Creating Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Public-Route_Table"
  }
}

### Creating Private Route Table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

### Route Table Association for Public Subnet
resource "aws_route_table_association" "public-subnet-route-1-association" {
  route_table_id  = aws_route_table.public-route-table.id
  subnet_id       = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "public-subnet-route-2-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public-subnet-2.id
}

resource "aws_route_table_association" "public-subnet-route-3-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id = aws_subnet.public-subnet-3.id
}

### Route Table Association for Private Subnet
resource "aws_route_table_association" "private-subnet-route-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-1.id
}

resource "aws_route_table_association" "private-subnet-route-2-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-2.id
}

resource "aws_route_table_association" "private-subnet-route-3-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id = aws_subnet.private-subnet-3.id
}

### Creating elastic ip
resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "Production-EIP"
  }
}

### Creating nat gw
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Production-NAT-GW"
  }

  depends_on = ["aws_eip.elastic-ip-for-nat-gw"]
}

### route nategateway
resource "aws_route" "nat-gw-route" {
  route_table_id          = aws_route_table.private-route-table.id
  nat_gateway_id          = aws_nat_gateway.nat-gw.id
  destination_cidr_block  = "0.0.0.0/0"
}

### creating internet gateway
resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "Production-IGW"
  }
}

### IGW route
resource "aws_route" "pubic-internet-gw-route" {
  route_table_id          = aws_route_table.public-route-table.id
  gateway_id              = aws_internet_gateway.production-igw.id
  destination_cidr_block  = "0.0.0.0/0"
}






