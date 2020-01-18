data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

resource "aws_key_pair" "key" {
  key_name   = "${random_id.key.hex}-key}"
  public_key = var.public_key
}

resource "aws_instance" "public" {
  ami           = data.aws_ami.amazon.id
  instance_type = var.private ? "t2.nano" : "m5.large"
  key_name      = aws_key_pair.key.key_name

  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size = var.private ? 8 : 50
    volume_type = "gp2"
  }

  user_data                   = (var.private ? 
                                  templatefile("${path.module}/bootstrap.tmpl", {}) :
                                  templatefile("${path.module}/bootstrap-w-docker.tmpl",
                                      { kind_version = "0.7.0", kubectl_version = "1.17.1", golang_version = "1.13.6", compose_version = "1.25.1" , kustomize_version = "3.5.4"}))

  tags = {
    Name = random_id.key.hex
  }
}

output "ssh_access" {
  value = "ssh ec2-user@${aws_instance.public.public_ip}"
}

resource "aws_security_group" "personal" {
  count       = var.private ? 1 : 0
  name        = "${random_id.key.hex}-personal-sg"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.personal_ip}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.personal_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private" {
  count         = var.private ? 1 : 0
  ami           = data.aws_ami.amazon.id
  instance_type = "t2.nano"
  key_name      = aws_key_pair.key.key_name

  vpc_security_group_ids      = [aws_security_group.personal[count.index].id]
  subnet_id                   = aws_subnet.private[count.index].id
  associate_public_ip_address = false
  user_data                   = templatefile("${path.module}/bootstrap.tmpl", {})

  tags = {
    Name = random_id.key.hex
  }
}

