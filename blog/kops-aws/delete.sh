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
    exit 1
fi

export CLUSTER=red.$DOMAIN
export BUCKET=kops-$CLUSTER
export KOPS_STATE_STORE=s3://$BUCKET
export REGION=eu-west-1
unset AWS_DEFAULT_PROFILE
export PATH=$(pwd):$PATH
export AWS_ACCESS_KEY_ID=$(cat .$CLUSTER-access-key |jq -r '.AccessKey.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(cat .$CLUSTER-access-key |jq -r '.AccessKey.SecretAccessKey')
export AWS_DEFAULT_REGION=$REGION

# Delete the cluster and bucket as kops
kops delete cluster --name=$CLUSTER --yes

aws s3 rm $KOPS_STATE_STORE/ --recursive
aws s3api delete-bucket \
    --bucket=$BUCKET

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION

# Delete the user and group
aws iam delete-access-key --user-name kops \
    --access-key-id $(aws iam list-access-keys --user-name kops --query='AccessKeyMetadata[0].AccessKeyId' --output=text)

aws iam remove-user-from-group --user-name kops --group-name kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
aws iam detach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
aws iam delete-group --group-name kops
aws iam delete-user --user-name kops
