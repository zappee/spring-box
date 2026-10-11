# ******************************************************************************
# Remal Hazelcast Platform Docker image build file.
#
# Since:  August 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Hazelcast ports:
#    -  5555: hazelcast public address of a member
#    -  5701: hazelcast uses to communicate between cluster members
#    - 54327: used to discover Hazelcast members
#    - 34500: hazelcast outbound-port
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
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

# environment variables
ENV IMAGE_NAME="$IMAGE_NAME" \
    IMAGE_TAG="$IMAGE_TAG" \
    IMAGE_AUTHOR="$IMAGE_AUTHOR" \
    IMAGE_DESCRIPTION="$IMAGE_DESCRIPTION" \
    \
    PKI_HOST="pki.remal.com" \
    KEYSTORE_HOME="/tmp" \
    \
    HAZELCAST_HOME="/opt/hazelcast" \
    HAZELCAST_CONFIG_TEMPLATE_DIR="/tmp/hazelcast-config-template" \
    HAZELCAST_INSTALL_KIT="hazelcast-5.6.0-slim.tar.gz" \
    HAZELCAST_CLUSTER_NAME="springbox-dev"

# set image metadata
LABEL "com.remal.image.name"="$IMAGE_NAME" \
      "com.remal.image.tag"="$IMAGE_TAG" \
      "com.remal.image.author"="$IMAGE_AUTHOR" \
      "com.remal.image.description"="$IMAGE_DESCRIPTION" \
      "com.remal.image.vendor"="Remal"

# fat image
FROM base AS base-fat
LABEL "com.remal.image.type"="fat"
COPY "bin/$HAZELCAST_INSTALL_KIT" "/tmp/"
RUN set -ue; \
    printf "building the fat image\n"; \
    mkdir -p "$HAZELCAST_HOME"; \
    tar -xvf "/tmp/$HAZELCAST_INSTALL_KIT" --strip-components=1 -C "$HAZELCAST_HOME"; \
    rm -f "/tmp/$HAZELCAST_INSTALL_KIT"

# slim image
FROM base AS base-slim
LABEL "com.remal.image.type"="slim"
RUN set -ue; \
    printf "building the slim image\n"; \
    host_ip="$(ip route | awk '/default/ { print $3 }')"; \
    wget -O "/tmp/$HAZELCAST_INSTALL_KIT" http://$host_ip:8080/docker-build/$HAZELCAST_INSTALL_KIT; \
    mkdir -p "$HAZELCAST_HOME"; \
    tar -xvf "/tmp/$HAZELCAST_INSTALL_KIT" --strip-components=1 -C "$HAZELCAST_HOME"; \
    rm -f "/tmp/$HAZELCAST_INSTALL_KIT"

# final image
FROM base-${BUILD_TYPE}

# ONBUILD COPY trigger fires behind the scenes.
# When this image is built, Docker looks back and says, "Ah, the parent image left a hidden note for
# me. It says I must automatically copy the scripts from my 'init' and 'startup' folder."


# Behind the scenes, Docker automatically runs the copy trigger here.
# It grabs "04-extended-addons" and puts it in the folder.


COPY container-scripts/hazelcast-functions.sh /
COPY config/hazelcast.xml "$HAZELCAST_CONFIG_TEMPLATE_DIR"/
