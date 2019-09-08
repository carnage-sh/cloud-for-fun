variable "kubkey" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDM/GTFl37upnwtTASS/moSTVWWR5+bizr6RAtZrmvLfO7N9m5z7FNV7mFrfMHxOYaTszRQFqVAiK4wnAqHt6rG6rWf4fmHs07JqGQHivvWcHTrE8s+BanKxcUiwvxa6G/T+mlEV2WcsS5bqkfTeRzbbzREFfahmool0Hv8Ioiu0IOcF+Lr2oMziiRJkdEOpEYY+oosdPQpH/mQf6qRmHnkC599JBARzKRzBpqEPgczdTtWTPkVT+iuoOFvU91JMZZesigKmcJWz3XfhRJRmah+BAlipmY+nY+U7lWeRzBaVqDZwHOS4N16G1qkgDkxyBuNmE3Jfm+cT2REKDH4AQj8DUs0D0fwmFvfpcNqj6h3ZDcl7LMAvJsLCZdS45KpgF9+4tevGKIloiGnkI1SQaucjcVvw04lQDG2surZP+uObfSXIXBHCXUBgtJiegr91O5ER4xs6WcJmBHIWiHU4Xu/Ln60DS4MXjCRcjpOdw+DcNW6j9DfHIjAaDHnPVypgUzoWKcCAiM7SEi7GmoW4KMHT4Vkofv57xPiRAUwyx+y8F2mTwfIQTd9ZP8DlxJNWgKDlA+lftjNa2mKfKN5wrOc8LGFQYjLgt2/BeeLn2sAS0h2tgCjFWF2PcuMQ+SUwxkY9/hs9Wt7QBEOkcGwqPw1rNRCO8njzGbQGRiz9PavaQ=="
}

resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "CostCenter" = "infrastructure:test"
    "Name"       = "test-vpc"
  }
}

data "aws_availability_zones" "az" {
}

data "aws_region" "current" {
}

resource "aws_key_pair" "ssh" {
  key_name   = "kubernetes-key"
  public_key = var.kubkey
}

resource "aws_subnet" "kubernetes_public_subnet" {
  count             = "3"
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = "10.42.${count.index}.0/24"

  tags = {
    "CostCenter" = "infrastructure:test"
    "Name"       = "test-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "CostCenter" = "infrastructure:test"
    "Name"       = "test-public-route"
  }
}

resource "aws_route_table_association" "public_subnet_table_association" {
  count          = 3
  subnet_id      = element(aws_subnet.kubernetes_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "kubernetes_private_subnet" {
  count             = "3"
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = "10.42.${3 + count.index}.0/24"

  tags = {
    "CostCenter" = "infrastructure:test"
    "Name"       = "test-private-subnet"
  }
}

resource "aws_eip" "natgw" {
  count = "1"
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  count         = "1"
  allocation_id = element(aws_eip.natgw.*.id, count.index)
  subnet_id     = element(aws_subnet.kubernetes_public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt_gw" {
  count  = 3
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }
}

resource "aws_route_table_association" "private-subnet-table-association" {
  count          = 3
  subnet_id      = element(aws_subnet.kubernetes_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt_gw.*.id, count.index)
}

