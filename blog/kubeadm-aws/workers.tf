resource "aws_iam_instance_profile" "kubernetes_worker_profile" {
  name = "kubernetes-worker-profile"
  role = aws_iam_role.kubernetes_worker_role.name
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
  role = aws_iam_role.kubernetes_worker_role.id

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
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:AttachNetworkInterface",
                 "ec2:DeleteNetworkInterface",
                 "ec2:DetachNetworkInterface",
                 "ec2:DescribeNetworkInterfaces",
                 "ec2:DescribeInstances",
                 "ec2:ModifyNetworkInterfaceAttribute",
                 "ec2:AssignPrivateIpAddresses",
                 "ec2:UnassignPrivateIpAddresses"
             ],
             "Resource": [
                 "*"
             ]
         },
         {
             "Effect": "Allow",
             "Action": "ec2:CreateTags",
             "Resource": "arn:aws:ec2:*:*:network-interface/*"
         },
         {
             "Effect": "Allow",
             "Action": [
                 "ecr:GetAuthorizationToken",
                 "ecr:BatchCheckLayerAvailability",
                 "ecr:GetDownloadUrlForLayer",
                 "ecr:GetRepositoryPolicy",
                 "ecr:DescribeRepositories",
                 "ecr:ListImages",
                 "ecr:BatchGetImage"
             ],
             "Resource": [
                "*"
             ]
         }
    ]
}
EOF

}

resource "aws_security_group" "k8s_worker" {
  name        = "kubernetes-worker"
  description = "Allow traffic to a Kubernetes WOrker node"
  vpc_id      = aws_vpc.main.id

  tags = {
    "CostCenter" = "infrastructure:test"
  }
}

resource "aws_security_group_rule" "k8s_worker_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.k8s_worker.id
}

resource "aws_security_group_rule" "k8s_worker_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.k8s_worker.id
}

locals {
  worker-userdata = <<EODATA
#!/bin/bash

set -e
set -o xtrace

cat <<EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF

yum -y update
yum install -y docker

mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

systemctl enable docker
systemctl start docker

yum install -y iproute-tc
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

cat <<EOF >/etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

modprobe br_netfilter

echo "Ready" >/root/bootstrap.me
EODATA
}

resource "aws_launch_configuration" "kubernetes_worker" {
  count                       = "1"
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.kubernetes_worker_profile.name
  image_id             = data.aws_ami.amazon-linux-2.id
  instance_type        = "m5.large"
  name_prefix          = "eks-kubernetes-worker"

  security_groups = [aws_security_group.k8s_worker.id]

  user_data_base64 = base64encode(local.worker-userdata)
  key_name         = aws_key_pair.ssh.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kubernetes_worker" {
  count = "1"

  desired_capacity     = "1"
  launch_configuration = element(aws_launch_configuration.kubernetes_worker.*.id, count.index)
  max_size             = 1
  min_size             = 1
  name                 = "eks-kubernetes-worker"
  vpc_zone_identifier  = [element(aws_subnet.kubernetes_private_subnet.*.id, count.index)]

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

  depends_on = [aws_route_table.private_rt_gw]
}

