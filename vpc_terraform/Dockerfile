FROM alpine:3.19

ENV TERRAFORM_VERSION=1.14.6
ENV KUBECTL_VERSION=v1.35.1
ENV HELM_VERSION=v4.1.1

WORKDIR /app

RUN apk --no-cache update \
  && apk upgrade \
  && apk --no-cache add curl git wget unzip openssh jq bind-tools bash python3 py3-pip ca-certificates groff less \
  && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O terraform.zip \
  && unzip terraform.zip \
  && chmod +x terraform \
  && mv terraform /usr/local/bin/terraform \
  && rm terraform.zip \
  && wget "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -O helm.tar.gz \
  && tar -xzvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf linux-amd64 helm.tar.gz \
  && curl -L -o kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && pip3 install --upgrade pip \
  && pip3 install awscli
