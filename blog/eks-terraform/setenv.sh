#!/usr/bin/env bash

set -e

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"eu-west-1"}
export CLUSTER=${CLUSTER:-princess}
export DIR=$(pwd)

# Step 2 - Create a KUBECONFIG file

cat >"$HOME/.kube/config" <<EOF
apiVersion: v1
clusters:
- cluster:
    server: $(aws eks describe-cluster --name "$CLUSTER" --query cluster.endpoint)
    certificate-authority-data: $(aws eks describe-cluster --name "$CLUSTER" --query cluster.certificateAuthority.data)
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "$CLUSTER"
EOF
