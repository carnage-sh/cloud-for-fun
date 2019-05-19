data "aws_ami" "bastion" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  most_recent = true
  owners      = ["137112412989"]
}

resource "aws_instance" "bastion" {
  count                       = "1"
  ami                         = data.aws_ami.bastion.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = element(aws_subnet.public-subnet.*.id, count.index)
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.sshkey.key_name

  tags = {
    CostCenter = "infrastructure"
    Name       = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Security group for the bastion"
  vpc_id      = aws_vpc.kubernetes.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group_rule" "bastion-ssh-ingress" {
  description       = "Allow SSH access to the bastion"
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
}

