resource "aws_iam_role" "worker-node" {
  name = "eks-${aws_eks_cluster.kubernetes.name}-worker"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy" "worker-node-external-dns" {
  name = "worker-node-external-dns"
  role = aws_iam_role.worker-node.name

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}

resource "aws_iam_instance_profile" "worker-node" {
  name = "eks-${aws_eks_cluster.kubernetes.name}-worker"
  role = aws_iam_role.worker-node.name
}

resource "aws_security_group" "worker-node" {
  name = "eks-${aws_eks_cluster.kubernetes.name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id = aws_vpc.kubernetes.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "eks-${aws_eks_cluster.kubernetes.name}-node"
    "kubernetes.io/cluster/${aws_eks_cluster.kubernetes.name}" = "owned"
  }
}

resource "aws_security_group_rule" "worker-node-ingress" {
  description = "Allow node to communicate with each other"
  from_port = 0
  protocol = "-1"
  to_port = 65535
  type = "ingress"
  security_group_id = aws_security_group.worker-node.id
  source_security_group_id = aws_security_group.worker-node.id
}

resource "aws_security_group_rule" "worker-node-ingress-cluster" {
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port = 1025
  protocol = "tcp"
  security_group_id = aws_security_group.worker-node.id
  source_security_group_id = aws_security_group.kubernetes.id
  to_port = 65535
  type = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-https" {
  description = "Allow pods to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.kubernetes.id
  source_security_group_id = aws_security_group.worker-node.id
  to_port = 443
  type = "ingress"
}

resource "aws_security_group_rule" "demo-cluster-ingress-node-ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.worker-node.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port = 22
  type = "ingress"
}

resource "aws_security_group_rule" "cluster-node-egress" {
  description = "Allow the cluster control plane to communicate with worker Kubelet and pods"
  from_port = 1025
  protocol = "tcp"
  to_port = 65535
  type = "egress"
  
  security_group_id = aws_security_group.kubernetes.id
  source_security_group_id = aws_security_group.worker-node.id
}

data "aws_ami" "eks-worker" {
  filter {
    name = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.kubernetes.version}-v*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }


  most_recent = true
  owners = ["602401143452"] # Amazon Account ID
}

data "aws_region" "current" {}

locals {
  worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.kubernetes.endpoint}' --b64-cluster-ca '${aws_eks_cluster.kubernetes.certificate_authority.0.data}' '${aws_eks_cluster.kubernetes.name}'
USERDATA
}

resource "aws_launch_configuration" "worker" {
  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.worker-node.name
  image_id             = data.aws_ami.eks-worker.id
  instance_type        = "m5.large"
  name_prefix          = "eks-${aws_eks_cluster.kubernetes.name}-worker"

  security_groups = [aws_security_group.worker-node.id]

  user_data_base64 = base64encode(local.worker-node-userdata)
  key_name         = aws_key_pair.sshkey.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.worker.id
  max_size             = 2
  min_size             = 1
  name                 = "eks-${aws_eks_cluster.kubernetes.name}-worker"
  vpc_zone_identifier  = aws_subnet.private-subnet.*.id

  tag {
    key                 = "Name"
    value               = "eks-${aws_eks_cluster.kubernetes.name}-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.kubernetes.name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
