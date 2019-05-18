resource "aws_vpc" "kubernetes" {
  cidr_block           = "10.4.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "CostCenter"                                             = "infrastructure"
    "Name"                                                   = "kubernetes"
    "kubernetes.io/cluster/${var.name[terraform.workspace]}" = "shared"
  }
}

resource "aws_route53_zone" "internal" {
  name = "${var.name[terraform.workspace]}.kubernetes"

  vpc_id = aws_vpc.kubernetes.id
}

data "aws_availability_zones" "az" {
}

resource "aws_subnet" "public-subnet" {
  count             = "3"
  vpc_id            = aws_vpc.kubernetes.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = "10.4.${count.index + 1}.0/24"

  tags = {
    "CostCenter"                                             = "infrastructure"
    "Name"                                                   = "public-${var.name[terraform.workspace]}-${count.index}"
    "kubernetes.io/cluster/${var.name[terraform.workspace]}" = "shared"
    "kubernetes.io/role/elb"                                 = ""
  }
}

resource "aws_subnet" "private-subnet" {
  count             = "3"
  vpc_id            = aws_vpc.kubernetes.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = "10.4.${count.index + 4}.0/24"

  tags = {
    "CostCenter"                                             = "infrastructure"
    "Name"                                                   = "private-${var.name[terraform.workspace]}-${count.index}"
    "kubernetes.io/cluster/${var.name[terraform.workspace]}" = "shared"
    "kubernetes.io/role/elb"                                 = ""
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kubernetes.id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.kubernetes.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet-table-association" {
  count          = 3
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_eip" "natgw" {
  count = 1
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  count         = "1"
  allocation_id = element(aws_eip.natgw.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private-route-table" {
  count  = 3
  vpc_id = aws_vpc.kubernetes.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }
}

resource "aws_route_table_association" "private-subnet-table-association" {
  count          = 3
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}

