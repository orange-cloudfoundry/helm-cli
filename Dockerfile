FROM ubuntu:16.04
USER root
ARG DEBIAN_FRONTEND=noninteractive

#--- Packages versions
ENV BUNDLER_VERSION="1.13.6" \
    KUBECTL_VERSION="1.10.2" \
    HELM_VERSION="2.9.1" \
"
ENV CONTAINER_LOGIN="bosh" CONTAINER_PASSWORD="welcome" \
    INIT_PACKAGES="apt-utils ca-certificates sudo wget curl unzip openssh-server openssl apt-transport-https" \
 

RUN echo "=====================================================" && \
    echo "=> Install system tools packages" && \
    echo "=====================================================" && \
    apt-get update && apt-get install -y --no-install-recommends ${INIT_PACKAGES} && apt-get upgrade -y && \
   
    echo "========================================================" && \
    echo "=> Create/setup user account, setup ssh and supervisor" && \
    echo "========================================================" && \
    echo "root:`date +%s | sha256sum | base64 | head -c 32 ; echo`" | chpasswd && \
    useradd -m -g users -G sudo,rvm -s /bin/bash ${CONTAINER_LOGIN} && \
    echo "${CONTAINER_LOGIN}:${CONTAINER_PASSWORD}" | chpasswd && chage -d 0 ${CONTAINER_LOGIN} && \
    echo "${CONTAINER_LOGIN} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${CONTAINER_LOGIN} && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    sed -i 's/^PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config && \
    sed -i 's/.*\[supervisord\].*/&\nnodaemon=true\nloglevel=debug/' /etc/supervisor/supervisord.conf && \
    sed -i "s/<username>/${CONTAINER_LOGIN}/g" /usr/local/bin/supervisord && \
    sed -i "s/<username>/${CONTAINER_LOGIN}/g" /usr/local/bin/check_ssh_security && \
    sed -i "s/<username>/${CONTAINER_LOGIN}/g" /usr/local/bin/disable_ssh_password_auth && \
    mkdir -p /var/run/sshd /var/log/supervisor /data/shared/tools && \
    find /data -print0 | xargs -0 chown ${CONTAINER_LOGIN}:users && \
    chmod 700 /home/${CONTAINER_LOGIN} && chown -R ${CONTAINER_LOGIN}:users /home/${CONTAINER_LOGIN} && \
    chmod 644 /etc/bash_completion.d/bosh_completion && \
    echo "=====================================================" && \
    echo "=> Install ops tools" && \
    echo "=====================================================" && \
    wget "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -nv -O /usr/local/bin/kubectl && \
    wget "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" -nv -O - | tar -xz -C /tmp linux-amd64/helm && mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    echo "=====================================================" && \
    echo "=> Cleanup docker image" && \
    echo "=====================================================" && \
    rm -fr /tmp/* /var/tmp/*

