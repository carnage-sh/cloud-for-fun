# Overview

Kubernetes 1.13 has promoted `Kubeadm` to stable. This project provides a set
of resources to create a Kubernetes Cluster with Kubeadm and Terraform. It
relies on AWS but can easily be changed for another cloud provider or
on-premises resource.

# Create your environment with Terraform

The project assumes you've installed `terraform` on your system and you've set
your environment to do it. It also assumes you've configured a number of
dependencies, including:

- `awscli` and an associated configuration so that `aws sts get-caller-identity`
  can work and the associated IAM profile as enough privileges to create the
  resources defined as part of the Terraform stack.
- `git`. As a matter of fact, you should have cloned or fork the project
- `~/.ssh/id_rsa.pub` contains a public key for your environment. It is important
  since otherwise the key you'll get will be the default project key
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
cd episode-002
terraform init
terraform apply
```

Once the instance started, you should be able to connect with the commands
below:

```bash
export BASTION=$(terraform state show "aws_instance.bastion[0]" \
  | grep public_dns | cut -d'"' -f2)
export PLANE=$(terraform state show "aws_instance.controlplane[0]" \
  | grep private_dns | cut -d'"' -f2)
export WORKER=$(terraform state show "aws_instance.worker[0]" \
  | grep private_dns | cut -d'"' -f2)

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -J fedora@$BASTION admin@$PLANE
```

> Note: the environment creates most of its resources as part of a VPC
  named `kubernetes` so that, if you loose the configuration, it can
  be easily destroyed. It also store the `terraform` state locally. You
  should be able to delete all the resources with a `terraform destroy`
  when you are done.

# Installing required packages

All the nodes required packages, including docker, kubectl, kubeadmin
and kubelet are part of the instance Cloud-Init script. There is nothing
to configure as part of the installation because of it. For details about
what to install, review the `cloudinit.sh` script.

# Install the first cluster node with kubeadm

On the first cluster node, run the following command to initialize the
cluster:

```bash
sudo su -
kubeadm init --pod-network-cidr=192.168.0.0/16
```

Once you've initialized the cluster, you can easily add Calico to your
configuration:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config 
curl -LO https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
kubectl apply -f calico.yaml
```

> Note: In order for Kubernetes and Calico to work, you need to open a proper
  set of port/protocol. The terraform resources include the correct set of
  security rules.

Once done, you should be able to make the 2nd node join the cluster with a of
commands like the one below. You should copy the `kubeadm join` command from
the output of the `kubeadm init` command:

```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -J fedora@$BASTION admin@$WORKER
sudo su -
kubeadm join 10.7...:6443 --token ... --discovery-token-ca-cert-hash sha256:1d32...
```

# Test your cluster configuration

Create the following file and name it `nginx.yaml` on the master node:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.15.6
        ports:
        - containerPort: 80
```

You should be able to run the command below to create a deployment and
monitor the associated pods are starting:

```yaml
kubectl apply -f nginx.yaml
```

# Summary

In this episode, we've:

- Created a simple infrastructure with Terraform 0.12
- Installed docker, kubeadm, kubectl and kubelet
- Created a single-node master Kubernetes
- Deployed Calico as a CNI
- Joined a worked node
- Started a set of pods running Nginx as part of a deployment
- Tested the pod to make sure it is actually working as expected

To drop everything, you should simply run the following command:

```bash
terraform destroy
```

# Additional resources

If you want to know more about How to deploy kubernetes with KubeAdm and
Calico, you should read the following documentation.

- [Creating a single master cluster with kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
- [Installing Calico for policy and networking](https://docs.projectcalico.org/v3.4/getting-started/kubernetes/installation/calico)
