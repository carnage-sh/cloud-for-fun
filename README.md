# Overview

Kubernetes 1.13 has promoted Kubeadm to `stable`. This project provides a set
of resources to create a Kubernetes Cluster on AWS with Kubeadm and Terraform.

# Create your environment with Terraform

The project assumes you've installed `terraform` on your system and you've set
your environment to do it. It also assumes you've configured a number of
dependencies, including:

- `awscli` and an associated configuration so that `aws sts get-caller-identity`
  can work and the associated IAM profile as enough privileges to create the
  resources defined as part of the Terraform stack.
- `git`. As a matter of fact, you should have cloned or fork the project
- `~/.ssh/id_rsa.pub` contains a public key for your environment
- `bash` is installed and can ve set with `/usr/bin/env bash`

In order to proceed, you should run the set of commands below:

```bash
# Download Terraform v0.12
git rev-parse --show-toplevel
cd tools
./download.sh
# Add Terraform to your PATH
cd ..
source env.sh
```

Once configured, you should be able to create the Terraform configuration
with the following set of commands:

```bash
git rev-parse --show-toplevel
cd terraform
terraform init
terraform apply
```

Once the instance started, you should be able to connect with the commands
below:

```bash
export BASTION=$(terraform state show "aws_instance.bastion[0]" \
  | grep public_dns | cut -d'"' -f2)
export PLANE1=$(terraform state show "aws_instance.controlplane[0]" \
  | grep private_dns | cut -d'"' -f2)
export PLANE2=$(terraform state show "aws_instance.controlplane[1]" \
  | grep private_dns | cut -d'"' -f2)
export PLANE3=$(terraform state show "aws_instance.controlplane[2]" \
  | grep private_dns | cut -d'"' -f2)

ssh -J fedora@$BASTION fedora@$PLANE1 hostname
ssh -J fedora@$BASTION fedora@$PLANE2 hostname
ssh -J fedora@$BASTION fedora@$PLANE3 hostname
```

> Note: the environment creates most of its resources as part of a VPC
  named `kubernetes` so that, if you loose the configuration, it can
  be easily destroyed. It also store the `terraform` state locally. You
  should be able to delete all the resources with a `terraform destroy`
  when you are done.

# Installing Docker

```bash
sudo su -
dnf -y install dnf-plugins-core
dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo
dnf config-manager --set-enabled docker-ce-edge
dnf -y install docker-ce
systemctl start docker
docker ps
```

# Install kubeadm

```bash
sudo su -
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```

# Additional resources

- [Concepts Underlying the Cloud Controller Manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/)
- [In*Tree AWS Cloud Controller](https://github.com/kubernetes/kubernetes/tree/master/pkg/cloudprovider/providers/aws)
