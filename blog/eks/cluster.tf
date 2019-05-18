resource "aws_eks_cluster" "kubernetes" {
  name     = var.name[terraform.workspace]
  role_arn = aws_iam_role.kubernetes_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.kubernetes.id]
    subnet_ids = aws_subnet.public-subnet.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.kubernetes_cluster_policy,
    aws_iam_role_policy_attachment.kubernetes_service_policy,
  ]
}

resource "aws_iam_role" "kubernetes_role" {
  name = "${var.name[terraform.workspace]}KubernetesRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "kubernetes_cluster_policy" {
  role = aws_iam_role.kubernetes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "kubernetes_service_policy" {
  role = aws_iam_role.kubernetes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_key_pair" "sshkey" {
  key_name = "kubernetes"
  public_key = var.sshkey[terraform.workspace]
}

resource "aws_security_group" "kubernetes" {
  name = "${var.name[terraform.workspace]}-kubernetes"
  description = "Allow Kubernetes Access"
  vpc_id = aws_vpc.kubernetes.id
}

resource "aws_security_group_rule" "kunernetes_outbound_all" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.kubernetes.id
}

resource "aws_security_group_rule" "kunernetes_inbound_https" {
  type = "ingress"
  description = "Allow workstation to communicate with the cluster API Server"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.kubernetes.id
}

