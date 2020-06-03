# Creating VPC and subnets for nodes

resource "aws_vpc" "cluster-vpc" {
  cidr_block = var.network.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "az-1-private" {
  cidr_block = var.network.az-1-private
  vpc_id = aws_vpc.cluster-vpc.id
  availability_zone = var.az-1
  map_public_ip_on_launch = false
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "az-1-public" {
  cidr_block = var.network.az-1-public
  vpc_id = aws_vpc.cluster-vpc.id
  availability_zone = var.az-1
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "az-2-private" {
  cidr_block = var.network.az-2-private
  vpc_id = aws_vpc.cluster-vpc.id
  availability_zone = var.az-2
  map_public_ip_on_launch = false
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_subnet" "az-2-public" {
  cidr_block = var.network.az-2-public
  vpc_id = aws_vpc.cluster-vpc.id
  availability_zone = var.az-2
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

# Creating elastic ip's for the nat gateways

resource "aws_eip" "az-1-eip" {}
resource "aws_eip" "az-2-eip" {}

# Creating gateways

resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc.id
}

resource "aws_nat_gateway" "az-1-ngw" {
  allocation_id = aws_eip.az-1-eip.id
  subnet_id = aws_subnet.az-1-public.id
}

resource "aws_nat_gateway" "az-2-ngw" {
  allocation_id = aws_eip.az-2-eip.id
  subnet_id = aws_subnet.az-2-public.id
}

# Creating routes for the networks

resource "aws_route_table" "az-1" {
  vpc_id = aws_vpc.cluster-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az-1-ngw.id
  }
  tags = {
    Name = "az-a-rt"
  }
}

resource "aws_route_table" "az-2" {
  vpc_id = aws_vpc.cluster-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az-2-ngw.id
  }
}

resource "aws_route" "main_route" {
  route_table_id = aws_vpc.cluster-vpc.default_route_table_id
  gateway_id = aws_internet_gateway.cluster-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "rt-1-assoc" {
  route_table_id = aws_route_table.az-1.id
  subnet_id = aws_subnet.az-1-private.id
}

resource "aws_route_table_association" "rt-b-assoc" {
  route_table_id = aws_route_table.az-2.id
  subnet_id = aws_subnet.az-2-private.id
}
