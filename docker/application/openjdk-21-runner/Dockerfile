# *******************************************************************************
# Remal Spring-Box - Java JAR runner image build file.
#
# Since:  February 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************
ARG IMAGE_FROM="unknown"
ARG BUILD_TYPE="fat"
FROM ${IMAGE_FROM} AS base

EXPOSE 8443/tcp

ARG IMAGE_NAME="N/A"
ARG IMAGE_TAG="N/A"
ARG IMAGE_AUTHOR="N/A"
ARG IMAGE_DESCRIPTION="N/A"

# environment variables
ENV IMAGE_NAME="$IMAGE_NAME" \
    IMAGE_TAG="$IMAGE_TAG" \
    IMAGE_AUTHOR="$IMAGE_AUTHOR" \
    IMAGE_DESCRIPTION="$IMAGE_DESCRIPTION" \
    PKI_HOST="pki.remal.com" \
    KEYSTORE_HOME="/tmp" \
    CONSUL_SERVER_HOSTNAME="consul.hello.com" \
    HAZELCAST_CLUSTER_NAME="springbox-dev" \
    HAZELCAST_CLUSTER_MEMBERS="hazelcast-1.hello.com, hazelcast-2.hello.com" \
    JAR_HOME="/jar-to-run" \
    JAVA_OPTS="-Xms512m -Xmx512m -XX:+UseZGC" \
    JAVA_DEBUG="true" \
    JAVA_DEBUG_PORT=8000 \
    HEALTH_CHECK="true" \
    HEALTH_CHECK_URI="https://localhost:8443/actuator/health" \
    EXPECTED_HEALTH_CHECK_STATE='\"status\":\"UP\"'

# set image metadata
LABEL "com.remal.image.name"="$IMAGE_NAME" \
      "com.remal.image.tag"="$IMAGE_TAG" \
      "com.remal.image.author"="$IMAGE_AUTHOR" \
      "com.remal.image.description"="$IMAGE_DESCRIPTION" \
      "com.remal.image.vendor"="Remal"

# fat image
FROM base AS base-fat

# slim image
FROM base AS base-slim

# final image
FROM base-$BUILD_TYPE AS final

COPY config/consul-template.json "$CONSUL_CONFIG_TEMPLATE_DIR/"
COPY container-scripts/init/ /docker.init/
COPY container-scripts/startup/ /docker.startup/
