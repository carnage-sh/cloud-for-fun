#!/bin/sh

set -e

while true; do
  /root/ecr-helper.sh --push-and-pull ${KNATIVE_NAMESPACE} ${KNATIVE_SERVICEACCOUNT}
  sleep 14400
done

