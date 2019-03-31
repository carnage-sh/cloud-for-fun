resource "aws_iam_instance_profile" "kubernetes_worker_profile" {
  name = "kubernetes-worker-profile"
  role = "${aws_iam_role.kubernetes_worker_role.name}"
}

resource "aws_iam_role" "kubernetes_worker_role" {
  name = "kubernetes-worker-role"

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

resource "aws_iam_role_policy" "kubernetes_worker_role_policy" {
  name = "kubernetes-worker-role-policy"
  role = "${aws_iam_role.kubernetes_worker_role.id}"

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

resource "aws_security_group" "k8s_worker" {
  name        = "kubernetes-worker"
  description = "Allow traffic to a Kubernetes WOrker node"
  vpc_id      = "${aws_vpc.main.id}"

  tags = "${map(
    "CostCenter", "infrastructure:test"
  )}"
}

resource "aws_security_group_rule" "k8s_worker_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_worker.id}"
}

resource "aws_security_group_rule" "k8s_worker_kubelet" {
  type        = "ingress"
  from_port   = 10250
  to_port     = 10250
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_worker_servicenode" {
  type        = "ingress"
  from_port   = 30000
  to_port     = 32767
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_master.id}"
}

resource "aws_security_group_rule" "k8s_worker_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.k8s_worker.id}"
}

locals {
  worker-userdata = <<EOF
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

resource "aws_launch_configuration" "kubernetes_worker" {
  count                       = "1"
  associate_public_ip_address = false

  iam_instance_profile = "${aws_iam_instance_profile.kubernetes_worker_profile.name}"
  image_id             = "${data.aws_ami.ubuntu_ami.id}"
  instance_type        = "t2.medium"
  name_prefix          = "eks-kubernetes-worker"

  security_groups = ["${aws_security_group.k8s_worker.id}"]

  user_data_base64 = "${base64encode(local.worker-userdata)}"
  key_name         = "${aws_key_pair.ssh.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kubernetes_worker" {
  count = "1"

  desired_capacity     = "1"
  launch_configuration = "${element(aws_launch_configuration.kubernetes_worker.*.id, count.index)}"
  max_size             = 1
  min_size             = 1
  name                 = "eks-kubernetes-worker"
  vpc_zone_identifier  = ["${element(aws_subnet.kubernetes_private_subnet.*.id, count.index)}"]

  tag {
    key                 = "Name"
    value               = "eks-kubernetes-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCenter"
    value               = "infrastructure:test"
    propagate_at_launch = true
  }

  depends_on = ["aws_route_table.private_rt_gw"]
}
