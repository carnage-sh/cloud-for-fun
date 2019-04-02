resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow traffic to the bastion"
  vpc_id      = "${aws_vpc.main.id}"

  tags = "${map(
    "CostCenter", "infrastructure:test"
  )}"
}

resource "aws_security_group_rule" "bastion_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_internal" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["10.42.0.0/16"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion_bounce" {
  type        = "ingress"
  from_port   = 32768
  to_port     = 60999
  protocol    = "tcp"
  cidr_blocks = ["10.42.0.0/16"]

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_instance" "bastion" {
  count = "1"

  ami                    = "${data.aws_ami.ubuntu_ami.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  subnet_id                   = "${element(aws_subnet.kubernetes_public_subnet.*.id, count.index)}"
  associate_public_ip_address = "true"
  key_name                    = "${aws_key_pair.ssh.key_name}"

  tags {
    CostCenter = "infrastructure:test"
    Name       = "kubernetes-bastion"
  }
}
