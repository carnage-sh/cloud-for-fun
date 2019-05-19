output "region" {
  value = data.aws_region.current.name
}

output "cluster" {
  value = aws_eks_cluster.kubernetes.name
}

output "role" {
  value = aws_iam_role.worker-node.name
}

output "subnet" {
  value = aws_subnet.public-subnet.*.id
}

output "vpc" {
  value = aws_vpc.kubernetes.id
}

output "worker-securitygroup" {
  value = aws_security_group.worker-node.id
}

