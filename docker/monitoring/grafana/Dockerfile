# ******************************************************************************
# Remal Spring Box Grafana open-source analytics and visualization web
# application Docker image assemble and build file.
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
EXPOSE 3000/tcp

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
    PROMETHEUS_HOST="prometheus.remal.com" \
    PROMETHEUS_PORT="9090" \
    PROMETHEUS_PROTOCOL="https" \
    \
    GRAFANA_INSTALL_KIT="grafana-enterprise_12.4.0_22325204712_linux_amd64.tar.gz" \
    GRAFANA_HOME="/opt/grafana" \
    GRAFANA_PROTOCOL="https" \
    GRAFANA_PORT=3000 \
    GRAFANA_CONFIG="/opt/grafana/conf/custom.ini" \
    GRAFANA_PROVISIONING="/opt/grafana/conf/provisioning" \
    GRAFANA_STORAGE="/opt/grafana/data" \
    GRAFANA_LOG_DIR="/var/log/grafana" \
    GRAFANA_PLUGINS="/opt/grafana/data/plugins" \
    GRAFANA_USER="admin" \
    GRAFANA_PASSWORD="password"

# set image metadata
LABEL "com.remal.image.name"="$IMAGE_NAME" \
      "com.remal.image.tag"="$IMAGE_TAG" \
      "com.remal.image.author"="$IMAGE_AUTHOR" \
      "com.remal.image.description"="$IMAGE_DESCRIPTION" \
      "com.remal.image.vendor"="Remal"


# fat image
FROM base AS base-fat
COPY "bin/$GRAFANA_INSTALL_KIT" "/tmp/"
RUN set -ue; \
    mkdir -p "$GRAFANA_HOME"; \
    tar -xvf "/tmp/$GRAFANA_INSTALL_KIT" -C "$GRAFANA_HOME" --strip-components=1; \
    rm "/tmp/$GRAFANA_INSTALL_KIT"


# slim image
FROM base AS base-slim
RUN set -ue; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/$GRAFANA_INSTALL_KIT" http://$host_ip:8080/docker-build/$GRAFANA_INSTALL_KIT; \
    mkdir -p "$GRAFANA_HOME"; \
    tar -xvf "/tmp/$GRAFANA_INSTALL_KIT" -C "$GRAFANA_HOME" --strip-components=1; \
    rm "/tmp/$GRAFANA_INSTALL_KIT"


# final image
FROM base-$BUILD_TYPE AS final
RUN set -ue; \
    mkdir -p "$GRAFANA_STORAGE"; \
    mkdir -p "$GRAFANA_LOG_DIR"; \
    mkdir -p "$GRAFANA_PLUGINS"; \
    apk --no-cache add curl
COPY container-scripts/grafana-functions.sh /
COPY config/custom.ini "$GRAFANA_CONFIG"
COPY config/datasources/* "$GRAFANA_HOME/customization/datasources/"
