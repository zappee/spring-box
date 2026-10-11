# ******************************************************************************
#  Remal HashiCorp Vault Docker image build file.
#
#  Since:  July 2023
#  Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
#  Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
ARG IMAGE_FROM="unknown"
ARG BUILD_TYPE="fat"
FROM ${IMAGE_FROM} AS base

EXPOSE 22/tcp
EXPOSE 8200/tcp

ARG IMAGE_NAME="N/A"
ARG IMAGE_TAG="N/A"
ARG IMAGE_AUTHOR="N/A"
ARG IMAGE_DESCRIPTION="N/A"

# environment variables
ENV IMAGE_NAME="$IMAGE_NAME" \
    IMAGE_TAG="$IMAGE_TAG" \
    IMAGE_AUTHOR="$IMAGE_AUTHOR" \
    IMAGE_DESCRIPTION="$IMAGE_DESCRIPTION" \
    \
    PKI_HOST="pki.remal.com" \
    KEYSTORE_HOME="/tmp" \
    \
    VAULT_INSTALL_KIT="vault_1.21.4_linux_386.zip" \
    VAULT_CONFIG_FILE="/etc/vault.hcl" \
    VAULT_INIT_LOG="/var/log/vault-tokens.txt" \
    VAULT_FILE_STORE="/opt/vault/data" \
    VAULT_API_PORT="8200" \
    VAULT_LOG_LEVEL="info" \
    VAULT_LOG="/var/log/vault.log" \
    VAULT_AUDIT_LOG="/var/log/vault-audit.log"

# set image metadata
LABEL "com.remal.image.name"="$IMAGE_NAME" \
      "com.remal.image.tag"="$IMAGE_TAG" \
      "com.remal.image.author"="$IMAGE_AUTHOR" \
      "com.remal.image.description"="$IMAGE_DESCRIPTION" \
      "com.remal.image.vendor"="Remal"

# install openssl
RUN set -ue; \
    apk add --no-cache openssl


# fat image
FROM base AS base-fat
COPY "bin/$VAULT_INSTALL_KIT" "/tmp/"
RUN set -ue; \
    unzip "/tmp/$VAULT_INSTALL_KIT" -d "/usr/local/bin/"; \
    rm "/tmp/$VAULT_INSTALL_KIT"


# slim image
FROM base AS base-slim
RUN set -ue; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/$VAULT_INSTALL_KIT" http://$host_ip:8080/docker-build/$VAULT_INSTALL_KIT; \
    unzip "/tmp/$VAULT_INSTALL_KIT" -d "/usr/local/bin/"; \
    rm "/tmp/$VAULT_INSTALL_KIT"


# final image
FROM base-$BUILD_TYPE AS final
COPY config/vault.hcl "$VAULT_CONFIG_FILE"
COPY container-scripts/vault-functions.sh container-scripts/get-value.sh container-scripts/set-value.sh /
