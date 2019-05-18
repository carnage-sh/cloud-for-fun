#!/usr/bin/env bash

set -e

# Step 1: Set the different environment variables

export AWS_DEFAULT_REGION=$(terraform output region)
export CLUSTER=${CLUSTER:-princess}
ROLE=$(terraform state show aws_iam_role.worker-node | \
         grep "^arn"| awk '{print $3}')
export ROLE

# Step 2 - Deploy the aws-auth-cm so that the workers can join

curl -L -o- \
  https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/aws-auth-cm.yaml | \
  sed s~\<\.\*\>~${ROLE}~g | kubectl apply -f -

while true; do
  STATUS=$(kubectl get nodes --no-headers=true|awk '{print $2}')
  if [[ "$STATUS" == "Ready" ]]; then
    break
  fi
done

# Step 3 - Configure Dashboard

curl -L -o- \
  https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml  | \
  kubectl apply -f -

curl -L -o- \
  https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml  | \
  kubectl apply -f -

curl -L -o- \
  https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml | \
  sed 's/v1.5.2/v1.3.3/g' | \
  kubectl apply -f -

# curl -X GET https://k8s.gcr.io/v2/heapster-influxdb-amd64/tags/list

# Step 4 - Deploy Service Account

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: eks-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EOF
