#!/bin/bash

apt update && apt -y upgrade

# Install Docker
apt -y install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt update && apt -y install docker-ce
systemctl start docker
systemctl enable docker

# Install Kubectl, Kubeadm and Kubelet

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update && apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl start kubelet && systemctl enable kubelet 

# Pull Kubernetes Images

kubeadm config images pull

# Change configurable for Weave Network

echo "net.bridge.bridge-nf-call-iptables=1" > /etc/sysctl.d/01-weave.conf
sysctl --system

# Configure UTF-8 locales

locale-gen UTF-8
