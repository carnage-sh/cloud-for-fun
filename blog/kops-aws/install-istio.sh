#!/usr/bin/env bash

set -e

export export PATH=$(pwd)/istio-1.1.4/bin:$PATH
if [[ ! -d istio-1.1.4 ]]; then
  curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.4 sh -
  istioctl version
fi

cd istio-1.1.4
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
kubectl apply -f install/kubernetes/istio-demo.yaml
kubectl get svc -n istio-system
kubectl get pods -n istio-system
echo
echo "Make sure all pods are up..."
echo "kubectl get pods -n istio-system"
echo
kubectl label namespace default istio-injection=enabled


