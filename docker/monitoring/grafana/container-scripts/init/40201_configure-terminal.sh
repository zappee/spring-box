#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

log_start "$0"
{
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "KEYSTORE_HOME" "$KEYSTORE_HOME"
  printf "export %s=\"%s\"\n" "PROMETHEUS_HOST" "$PROMETHEUS_HOST"
  printf "export %s=\"%s\"\n" "PROMETHEUS_PORT" "$PROMETHEUS_PORT"
  printf "export %s=\"%s\"\n" "PROMETHEUS_PROTOCOL" "$PROMETHEUS_PROTOCOL"
  printf "export %s=\"%s\"\n" "GRAFANA_HOME" "$GRAFANA_HOME"
  printf "export %s=\"%s\"\n" "GRAFANA_PORT" "$GRAFANA_PORT"
  printf "export %s=\"%s\"\n" "GRAFANA_CONFIG" "$GRAFANA_CONFIG"
  printf "export %s=\"%s\"\n" "GRAFANA_PROVISIONING" "$GRAFANA_PROVISIONING"
  printf "export %s=\"%s\"\n" "GRAFANA_STORAGE" "$GRAFANA_STORAGE"
  printf "export %s=\"%s\"\n" "GRAFANA_LOG_DIR" "$GRAFANA_LOG_DIR"
  printf "export %s=\"%s\"\n" "GRAFANA_PLUGINS" "$GRAFANA_PLUGINS"
  printf "export %s=\"%s\"\n" "GRAFANA_USER" "$GRAFANA_USER"
  printf "export %s=\"%s\"\n" "GRAFANA_PASSWORD" "$GRAFANA_PASSWORD"
  printf "export %s=\"%s\"\n" "FQDN" "$(hostname -f)"
  printf "cd %s\n" "$GRAFANA_HOME"
} >> /etc/profile
log_end "$0"
