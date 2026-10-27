# ******************************************************************************
# Remal Spring Box ForgeRock Directory Services Docker image assemble and build
# file.
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

EXPOSE 22/tcp
EXPOSE 389/tcp
EXPOSE 636/tcp
EXPOSE 4444/tcp
EXPOSE 1331/tcp

ARG IMAGE_NAME="N/A"
ARG IMAGE_TAG="N/A"
ARG IMAGE_AUTHOR="N/A"
ARG IMAGE_DESCRIPTION="N/A"

# build time variables
ARG DS_HOME="/opt/opendj"

# environment variables
ENV IMAGE_NAME="${IMAGE_NAME}" \
    IMAGE_TAG="${IMAGE_TAG}" \
    IMAGE_AUTHOR="${IMAGE_AUTHOR}" \
    IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION}" \
    \
    AM_IDENTITY_STORE_NAME="am-identity-store" \
    AM_CONFIG_STORE_NAME="am-config" \
    \
    NEW_DS_DEPLOYMENT_KEY="false" \
    \
    DS_CONFIG_BACKUP="true" \
    DS_CONFIG_RESTORE_FROM="latest" \
    AM_IDENTITY_STORE_BACKUP="true" \
    AM_IDENTITY_STORE_RESTORE_FROM="latest" \
    AM_CONFIG_STORE_BACKUP="true" \
    AM_CONFIG_STORE_RESTORE_FROM="latest" \
    \
    ADMIN_CONNECTOR_PORT=4444 \
    PKI_HOST="pki.remal.com" \
    DS_HOST="ds.remal.com" \
    DS_HOME="$DS_HOME" \
    DEPLOYMENT_KEY_FILE="$DS_HOME/deployment-key.properties" \
    DS_INSTALL_KIT="DS-7.3.0.zip" \
    LDAP_PORT=389 \
    LDAP_USER_DN="uid=admin" \
    LDAP_USER_PASSWORD="password" \
    LDAPS_PORT=636

# set image metadata
LABEL "com.remal.image.name"="${IMAGE_NAME}" \
      "com.remal.image.tag"="${IMAGE_TAG}" \
      "com.remal.image.author"="${IMAGE_AUTHOR}" \
      "com.remal.image.description"="${IMAGE_DESCRIPTION}" \
      "com.remal.image.vendor"="Remal"


# fat image
FROM base AS base-fat
COPY "bin/${DS_INSTALL_KIT}" "/tmp/"
RUN unzip "/tmp/${DS_INSTALL_KIT}" -d "/opt/"


# slim image
FROM base AS base-slim
RUN set -ue; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/${DS_INSTALL_KIT}" http://${host_ip}:8080/docker-build/${DS_INSTALL_KIT}; \
    unzip "/tmp/${DS_INSTALL_KIT}" -d "/opt/"; \
    rm "/tmp/${DS_INSTALL_KIT}"


# final image
FROM base-${BUILD_TYPE} AS final
COPY container-scripts/ds-functions.sh container-scripts/shutdown-actions.sh /
COPY config/deployment-key.properties "${DS_HOME}/"
