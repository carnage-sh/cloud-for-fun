#!/usr/bin/env bash

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
VERSION="0.12.0-alpha4"
DISTRIB=https://releases.hashicorp.com/terraform

curl ${DISTRIB}/$VERSION/terraform_${VERSION}_terraform_${VERSION}_${OS}_amd64.zip \
    -o terraform_${VERSION}.zip
unzip terraform_${VERSION}.zip
rm -f terraform_${VERSION}.zip


