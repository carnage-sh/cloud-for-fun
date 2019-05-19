#!/usr/bin/env bash

set -e

# Step 1: Set the different environment variables

export AWS_DEFAULT_REGION=$(terraform output region)
export CLUSTER=${CLUSTER:-princess}
ROLE=$(terraform state show aws_iam_role.worker-node | \
         grep "arn"| awk '{print $3}')
export ROLE

# Step 2 - Deploy the aws-auth-cm so that the workers can join

curl -L -o- \
  https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-02-11/aws-auth-cm.yaml | \
  sed s~\<\.\*\>~${ROLE}~g | kubectl apply -f -

while true; do
  STATUS=$(kubectl get nodes --no-headers=true|awk '{print $2}')
  if [[ "$STATUS" == "Ready" ]]; then
    break
  fi
done

