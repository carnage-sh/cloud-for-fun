FROM debian:stretch

RUN apt update && apt install -y awscli jq curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /usr/local/bin/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/v1.14.0/bin/linux/amd64/kubectl \
    && curl -L -o /root/ecr-helper.sh \
      https://raw.githubusercontent.com/knative/build-templates/master/ecr_helper/helper.sh \
    && chmod +x /usr/local/bin/kubectl /root/ecr-helper.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

