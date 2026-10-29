# ******************************************************************************
# Remal Spring Box Hazelcast Plattform Docker image assemble and build file.
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
EXPOSE 5555/tcp
EXPOSE 5701/tcp

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
    \
    HAZELCAST_HOME="/opt/hazelcast" \
    HAZELCAST_CONFIG_TEMPLATE_DIR="/tmp/hazelcast-config-template" \
    HAZELCAST_INSTALL_KIT="hazelcast-5.6.0-slim.tar.gz" \
    HAZELCAST_CLUSTER_NAME="springbox-dev"

# Image metadata labels
LABEL "com.remal.image.name"="${IMAGE_NAME}" \
      "com.remal.image.tag"="${IMAGE_TAG}" \
      "com.remal.image.author"="${IMAGE_AUTHOR}" \
      "com.remal.image.description"="${IMAGE_DESCRIPTION}" \
      "com.remal.image.vendor"="Remal"

# Fat image stage
FROM base AS base-fat
LABEL "com.remal.image.type"="fat"
COPY "bin/${HAZELCAST_INSTALL_KIT}" "/tmp/"
RUN set -ue; \
    printf "building the fat image\n"; \
    mkdir -p "${HAZELCAST_HOME}"; \
    tar -xvf "/tmp/${HAZELCAST_INSTALL_KIT}" --strip-components=1 -C "${HAZELCAST_HOME}"; \
    rm -f "/tmp/${HAZELCAST_INSTALL_KIT}"


# Slim image stage
FROM base AS base-slim
LABEL "com.remal.image.type"="slim"
RUN set -ue; \
    printf "building the slim image\n"; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/${HAZELCAST_INSTALL_KIT}" http://${host_ip}:8080/docker-build/${HAZELCAST_INSTALL_KIT}; \
    mkdir -p "${HAZELCAST_HOME}"; \
    tar -xvf "/tmp/${HAZELCAST_INSTALL_KIT}" --strip-components=1 -C "${HAZELCAST_HOME}"; \
    rm -f "/tmp/${HAZELCAST_INSTALL_KIT}"


# Final image composition stage
FROM base-${BUILD_TYPE}
COPY container-scripts/hazelcast-functions.sh /
COPY config/hazelcast.xml "${HAZELCAST_CONFIG_TEMPLATE_DIR}"/
