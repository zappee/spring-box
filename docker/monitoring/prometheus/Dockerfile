# ******************************************************************************
# Remal Spring Box Prometheus event monitoring and alerting software Docker
# image assemble and build file.
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
EXPOSE 9090/tcp

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
    CONSUL_HOST="consul.remal.com" \
    \
    PROMETHEUS_INSTALL_KIT="prometheus-3.10.0.linux-amd64.tar.gz" \
    PROMETHEUS_HOME="/opt/prometheus" \
    PROMETHEUS_CONFIG="/opt/prometheus/prometheus.yml" \
    PROMETHEUS_WEB_CONFIG="/opt/prometheus/web-config.yml" \
    PROMETHEUS_LOG="/var/log/prometheus.log" \
    PROMETHEUS_STORAGE="/opt/prometheus/data"

# set image metadata
LABEL "com.remal.image.name"="$IMAGE_NAME" \
      "com.remal.image.tag"="$IMAGE_TAG" \
      "com.remal.image.author"="$IMAGE_AUTHOR" \
      "com.remal.image.description"="$IMAGE_DESCRIPTION" \
      "com.remal.image.vendor"="Remal"


# fat image
FROM base AS base-fat
COPY "bin/$PROMETHEUS_INSTALL_KIT" "/tmp/"
RUN set -ue; \
    tar -xvf "/tmp/$PROMETHEUS_INSTALL_KIT" -C "$(dirname "$PROMETHEUS_HOME")"; \
    mv "$(dirname "$PROMETHEUS_HOME")/${PROMETHEUS_INSTALL_KIT/.tar.gz/}" "$PROMETHEUS_HOME"; \
    rm "/tmp/$PROMETHEUS_INSTALL_KIT"


# slim image
FROM base AS base-slim
RUN set -ue; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/$PROMETHEUS_INSTALL_KIT" http://$host_ip:8080/docker-build/$PROMETHEUS_INSTALL_KIT; \
    tar -xvf "/tmp/$PROMETHEUS_INSTALL_KIT" -C "$(dirname "$PROMETHEUS_HOME")"; \
    mv "$(dirname "$PROMETHEUS_HOME")/${PROMETHEUS_INSTALL_KIT/.tar.gz/}" "$PROMETHEUS_HOME"; \
    rm "/tmp/$PROMETHEUS_INSTALL_KIT"


# final image
FROM base-$BUILD_TYPE AS final
RUN set -ue; \
    mkdir -p "$PROMETHEUS_STORAGE"
COPY config/*.yml "$PROMETHEUS_HOME/"
