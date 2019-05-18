#!/usr/bin/env bash

set -e

kubectl -n kube-system describe secret \
  "$(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')"

echo
echo "http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
echo

kubectl proxy 
