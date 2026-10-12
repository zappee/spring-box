#!/bin/bash -ue
# ******************************************************************************
# Bash environment setup for a Docker container.
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
