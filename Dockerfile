FROM ubuntu:16.04
USER root
ARG DEBIAN_FRONTEND=noninteractive
#--- Packages versions
ENV KUBECTL_VERSION="1.10.2" \
    HELM_VERSION="2.10.0" 
ENV CONTAINER_LOGIN="bosh" CONTAINER_PASSWORD="welcome" \
    INIT_PACKAGES="apt-utils ca-certificates sudo wget curl unzip openssh-server openssl apt-transport-https" 
 
RUN echo "=====================================================" && \
    echo "=> Install system tools packages" && \
    echo "=====================================================" && \
    apt-get update && apt-get install -y --no-install-recommends ${INIT_PACKAGES} && apt-get upgrade -y && \
    wget "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -nv -O /usr/local/bin/kubectl && \
    wget "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" -nv -O - | tar -xz -C /tmp linux-amd64/helm && mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    echo "=====================================================" && \
    echo "=> Cleanup docker image" && \
    echo "=====================================================" && \
    rm -fr /tmp/* /var/tmp/*

