resource "aws_instance" "bastion" {
  count = 1

  ami                         = data.aws_ami.fedora.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [ aws_security_group.ssh_inbound.id ]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssh_profile.id
  subnet_id                   = aws_subnet.public-subnet.1.id
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.sshkey.key_name

  tags = {
    Name = "kubernetes-bastion"
  }
}

resource "aws_instance" "controlplane" {
  count = 3

  ami                         = data.aws_ami.fedora.id
  instance_type               = "m5.large"
  vpc_security_group_ids      = [ aws_security_group.ssh_inbound.id, aws_security_group.kubernetes.id ]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssh_profile.id
  subnet_id                   = element(aws_subnet.private-subnet.*.id, count.index)
  associate_public_ip_address = "false"
  key_name                    = aws_key_pair.sshkey.key_name

  tags = {
    Name = "control-plane-${count.index+1}"
  }
}

resource "random_id" "sshkey" {
  byte_length = 12
}

resource "aws_key_pair" "sshkey" {
  key_name   = random_id.sshkey.hex
  public_key = var.sshkey
}

resource "aws_iam_instance_profile" "ec2_ssh_profile" {
  name = "KubernetesRoleProfile"
  role = aws_iam_role.ec2_bastion_role.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ec2_bastion_role" {
  name = "KubernetesRole"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_bastion_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "KubernetesRolePolicy"
  path        = "/"
  description = "Policy used to access Configuration"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DescribeAlarms",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:PutMetricData",
        "ec2:Describe*",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
