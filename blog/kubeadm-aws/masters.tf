resource "aws_security_group" "k8s_master" {
  name        = "kubernetes-master"
  description = "Allow traffic to a Kubernetes master node"
  vpc_id      = "${aws_vpc.main.id}"
}

resource "aws_security_group_rule" "k8s_master_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_apiserver" {
  type        = "ingress"
  from_port   = 6443
  to_port     = 6443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_etcd" {
  type        = "ingress"
  from_port   = 2379
  to_port     = 2380
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_kubelet" {
  type        = "ingress"
  from_port   = 10250
  to_port     = 10250
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_kubescheduler" {
  type        = "ingress"
  from_port   = 10251
  to_port     = 10251
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_kubecontroller" {
  type        = "ingress"
  from_port   = 10252
  to_port     = 10252
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_master_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_iam_instance_profile" "kubernetes_master_profile" {
  name = "kubernetes-master-profile"
  role = "${aws_iam_role.kubernetes_master_role.name}"
}

resource "aws_iam_role" "kubernetes_master_role" {
  name = "kubernetes-master-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubernetes_master_role_policy" {
  name = "kubernetes-master-role-policy"
  role = "${aws_iam_role.kubernetes_master_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "iam:ListAccessKeys"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  master-userdata = <<EOF
#!/bin/bash

set -e
set -o xtrace
apt update
apt install -y docker.io

systemctl enable docker.service

apt install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list

apt update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "Ready" >/root/bootstrap.me
EOF
}

resource "aws_launch_configuration" "kubernetes_master" {
  count                       = "1"
  associate_public_ip_address = false

  iam_instance_profile = "${aws_iam_instance_profile.kubernetes_master_profile.name}"
  image_id             = "${data.aws_ami.ubuntu_ami.id}"
  instance_type        = "t2.medium"
  name_prefix          = "eks-kubernetes-master"

  security_groups = ["${aws_security_group.k8s_master.id}"]

  user_data_base64 = "${base64encode(local.master-userdata)}"
  key_name         = "${aws_key_pair.ssh.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kubernetes_master" {
  count = "1"

  desired_capacity     = "1"
  launch_configuration = "${element(aws_launch_configuration.kubernetes_master.*.id, count.index)}"
  max_size             = 1
  min_size             = 1
  name                 = "eks-kubernetes-master"
  vpc_zone_identifier  = ["${element(aws_subnet.kubernetes_private_subnet.*.id, count.index)}"]

  tag {
    key                 = "Name"
    value               = "eks-kubernetes-master"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCenter"
    value               = "infrastructure:test"
    propagate_at_launch = true
  }

  depends_on = ["aws_route_table.private_rt_gw"]
}
