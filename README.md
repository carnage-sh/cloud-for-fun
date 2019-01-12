# Overview

Kubernetes 1.13 has promoted Kubeadm to `stable`. This project provides a set
of resources to create a Kubernetes Cluster on AWS with Kubeadm and Terraform.

# Install and configure Terraform

The project assumes you've installed `terraform` on your system and you've set
your environment to do it. In order to proceed on any `bash` friendly
environment, you should run the set of commands below:

```bash
# Download Terraform v0.12
git rev-parse --show-toplevel
cd tools
./download.sh
# Add Terraform to your PATH
cd ..
source env.sh
```

# Additional resources

- [Concepts Underlying the Cloud Controller Manager](https://kubernetes.io/docs/concepts/architecture/cloud-controller/)
- [](https://github.com/kubernetes/kubernetes/tree/master/pkg/cloudprovider/providers/aws)
- [K8S AWS Cloud Provider Notes](https://docs.google.com/document/d/17d4qinC_HnIwrK0GHnRlD1FKkTNdN__VO4TH9-EzbIY/edit)
