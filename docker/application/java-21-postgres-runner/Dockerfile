# ******************************************************************************
# Remal Spring Box OpenJDK 21 with PostgreSQL database server Docker image
# assemble and build file.
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

EXPOSE 5432/tcp

ARG IMAGE_NAME="N/A"
ARG IMAGE_TAG="N/A"
ARG IMAGE_AUTHOR="N/A"
ARG IMAGE_DESCRIPTION="N/A"

# environment variables
ENV IMAGE_NAME="${IMAGE_NAME}" \
    IMAGE_TAG="${IMAGE_TAG}" \
    IMAGE_AUTHOR="${IMAGE_AUTHOR}" \
    IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION}" \
    \
    POSTGRES_HOME="/var/lib/postgresql" \
    POSTGRES_DATA="/var/lib/postgresql/data" \
    POSTGRES_LOG_DIR="/var/log/postgresql" \
    POSTGRES_CONFIG="/var/lib/postgresql/data/postgresql.conf" \
    START_DB="false" \
    \
    DB_ADMIN_USER="postgres" \
    DB_ADMIN_PASSWORD="password" \
    DB_APP_DATABASE="app" \
    DB_APP_USER="application" \
    DB_APP_PASSWORD="password"

# set image metadata
LABEL "com.remal.image.name"="${IMAGE_NAME}" \
      "com.remal.image.tag"="${IMAGE_TAG}" \
      "com.remal.image.author"="${IMAGE_AUTHOR}" \
      "com.remal.image.description"="${IMAGE_DESCRIPTION}" \
      "com.remal.image.vendor"="Remal"

# fat image
FROM base AS base-fat

# slim image
FROM base AS base-slim

# final image
FROM base-${BUILD_TYPE} AS final

# installing tools
RUN set -ue; \
    apk add --no-cache postgresql18; \
    mkdir -p /run/postgresql; \
    chown postgres:postgres /run/postgresql/

# copy files
COPY --chown=postgres:postgres config/*.conf /tmp/
COPY container-scripts/init/* /docker.init/
COPY container-scripts/startup/* /docker.startup/
COPY container-scripts/*.sh /
