variable kubkey {
  type    = "string"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDLqoFOCVbo2la8AOnN2PvYMCbPsBx8y51CT1Jx2wjbQoyqR81IgOSYCH/+aGv3XD6nDDdzSoVRcv5ddMisWWet7DcXSbjfoACIFTpa2rWcNCwe3q6VUmD7kYlHLQyc/GGJJZ0iir0fCmD2pKNYWYEKimijzJeE4oSeLHlLOB2XShNmuCx4i58HAcQdTR2H+PRZfu3lUNLZ7AF4FATrzz7keULnTQj9bCSk+ThSnm3V6LPHCPSDyOhW8q/Z5b3+URYM7b/WAVnbVq0UVVAbupKrJHn+WFBlLcgCcvILkWpRXg0HU7JbXprKexECGW60zd1LS3R1NkOLK131mWfHDpl"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true

  tags = "${map(
    "CostCenter", "infrastructure:test",
     "Name", "test-vpc"
  )}"
}

data "aws_availability_zones" "az" {}
data "aws_region" "current" {}

resource "aws_key_pair" "ssh" {
  key_name   = "kubernetes-key"
  public_key = "${var.kubkey}"
}

resource "aws_subnet" "kubernetes_public_subnet" {
  count             = "3"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  cidr_block        = "10.42.${count.index}.0/24"

  tags = "${map(
    "CostCenter", "infrastructure:test",
     "Name", "test-public-subnet"
  )}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = "${map(
    "CostCenter", "infrastructure:test",
     "Name", "test-public-route"
  )}"
}

resource "aws_route_table_association" "public_subnet_table_association" {
  count          = 3
  subnet_id      = "${element(aws_subnet.kubernetes_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_subnet" "kubernetes_private_subnet" {
  count             = "3"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  cidr_block        = "10.42.${3 + count.index}.0/24"

  tags = "${map(
    "CostCenter", "infrastructure:test",
     "Name", "test-private-subnet"
  )}"
}

resource "aws_eip" "natgw" {
  count = "1"
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  count         = "1"
  allocation_id = "${element(aws_eip.natgw.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.kubernetes_public_subnet.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "private_rt_gw" {
  count  = 3
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private-subnet-table-association" {
  count          = 3
  subnet_id      = "${element(aws_subnet.kubernetes_private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_rt_gw.*.id, count.index)}"
}
