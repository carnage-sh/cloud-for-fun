#!/usr/bin/env bash

set -e

while getopts "c:d:" arg; do
  case $arg in
    c)
      CLUSTER=$OPTARG
      ;;
    d)
      DOMAIN=$OPTARG
      ;;
  esac
done

if [[ -z "$DOMAIN" || -z "$CLUSTER" ]]; then
    echo "Add the -d [domain] with a domain, the zone is managed and -c [cluster]"
    echo " For instance, to create red.resetlogs.com, run:"
    echo " ./install.sh -d resetlogs.com -c red"
    exit 0
fi

export CLUSTER=red.$DOMAIN
export BUCKET=kops-$CLUSTER
export KOPS_STATE_STORE=s3://$BUCKET
export REGION=eu-west-1
export KOPS_URL="https://github.com/kubernetes/kops/releases/download/1.14.0-alpha.1/kops-darwin-amd64"
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION AWS_DEFAULT_PROFILE

# Download and test kops
curl -L $KOPS_URL -o kops
export PATH=$(pwd):$PATH
chmod +x kops
kops version

# Create a dedicated user/group with the required permissions
aws iam create-group --group-name kops

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops

aws iam create-user --user-name kops
aws iam add-user-to-group --user-name kops --group-name kops
aws iam create-access-key --user-name kops >.$CLUSTER-access-key

# Set the access key for kops
export AWS_ACCESS_KEY_ID="$(cat .$CLUSTER-access-key |jq -r '.AccessKey.AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(cat .$CLUSTER-access-key |jq -r '.AccessKey.SecretAccessKey')"
export AWS_DEFAULT_REGION="$REGION"

sleep 30
aws sts get-caller-identity

# Create a bucket to keep the cluster state files
aws s3api create-bucket \
    --bucket=$BUCKET \
    --region=$REGION \
    --create-bucket-configuration LocationConstraint=$REGION

sleep 5

# Create the cluster
echo kops create cluster --name=$CLUSTER --zones=${REGION}a
kops create cluster --name=$CLUSTER --zones=${REGION}a
echo kops update cluster --name=$CLUSTER --yes
kops update cluster --name=$CLUSTER --yes

# Check the cluster starts as expected
for i in $(seq 90); do
    sleep 10
    OK=$(kops validate cluster -o json 2>/dev/null |jq -r '.nodes[] | select (.role=="master") | .status' || true)
    echo -n "."
    if [[ "$OK" == "True" ]]; then
        echo "Cluster $CLUSTER created with success"
        exit 0
    fi
done

echo "Cluster $CLUSTER creation failed"
exit 1

