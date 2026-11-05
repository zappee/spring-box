# ******************************************************************************
# Remal Spring Box HashiCorp Vault Docker image assemble and build file.
#
# Credits:
#   Contact:   arnold.somogyi@gmail.com
#   Copyright: Copyright (c) 2020-2026 Remal Software
#
#   This work is licensed under the Creative Commons Attribution-
#   NonCommercial 4.0 International License. To view a copy of this license,
#   visit: https://creativecommons.org
#
#   You are free to share and adapt the material for personal or hobby
#   purposes, provided you give appropriate credit and do not use the material
#   for commercial gain.
# ******************************************************************************
ARG IMAGE_FROM="unknown"
ARG BUILD_TYPE="fat"
FROM ${IMAGE_FROM} AS base

EXPOSE 8200/tcp
EXPOSE 8201/tcp

ARG IMAGE_NAME="N/A"
ARG IMAGE_TAG="N/A"
ARG IMAGE_AUTHOR="N/A"
ARG IMAGE_DESCRIPTION="N/A"

# Environment configurations
ENV IMAGE_NAME="${IMAGE_NAME}" \
    IMAGE_TAG="${IMAGE_TAG}" \
    IMAGE_AUTHOR="${IMAGE_AUTHOR}" \
    IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION}" \
    \
    PKI_HOST="pki.remal.com" \
    KEYSTORE_HOME="/tmp" \
    ROOT_CA_BASENAME="ca" \
    VAULT_INSTALL_KIT="vault_2.2.1_linux_386.zip" \
    \
    VAULT_CONFIG_FILE="/etc/vault.hcl" \
    VAULT_FILE_STORE="/opt/vault/data" \
    VAULT_CLUSTER_NAME="springbox-vault-cluster" \
    \
    VAULT_LOG_LEVEL="info" \
    VAULT_INIT_LOG="/var/log/vault-tokens.txt" \
    VAULT_LOG="/var/log/vault.log" \
    VAULT_AUDIT_LOG="/var/log/vault-audit.log" \
    \
    VAULT_TCP_HOST="0.0.0.0" \
    VAULT_TCP_PORT="8200" \
    \
    VAULT_API_PROTOCOL="https" \
    VAULT_API_HOST="127.0.0.1" \
    VAULT_API_PORT="8200" \
    \
    VAULT_CLUSTER_PROTOCOL="https" \
    VAULT_CLUSTER_HOST="0.0.0.0" \
    VAULT_CLUSTER_PORT="8201"

# Image metadata labels
LABEL "com.remal.image.name"="${IMAGE_NAME}" \
      "com.remal.image.tag"="${IMAGE_TAG}" \
      "com.remal.image.author"="${IMAGE_AUTHOR}" \
      "com.remal.image.description"="${IMAGE_DESCRIPTION}" \
      "com.remal.image.vendor"="Remal"

# Install system tools
RUN set -ue; \
    apk add --no-cache openssl

# Fat image stage
FROM base AS base-fat
COPY "bin/${VAULT_INSTALL_KIT}" "/tmp/"
RUN set -ue; \
    unzip "/tmp/${VAULT_INSTALL_KIT}" -d "/usr/local/bin/"; \
    rm "/tmp/${VAULT_INSTALL_KIT}"

# Slim image stage
FROM base AS base-slim
RUN set -ue; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/${VAULT_INSTALL_KIT}" http://${host_ip}:8080/docker-build/${VAULT_INSTALL_KIT}; \
    unzip "/tmp/${VAULT_INSTALL_KIT}" -d "/usr/local/bin/"; \
    rm "/tmp/${VAULT_INSTALL_KIT}"

# Final image composition stage
FROM base-${BUILD_TYPE} AS final
COPY config/vault.hcl "${VAULT_CONFIG_FILE}"
COPY container-scripts/vault-functions.sh container-scripts/get-value.sh container-scripts/set-value.sh /
