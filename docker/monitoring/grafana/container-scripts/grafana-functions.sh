#!/bin/bash -ue
# ******************************************************************************
# Grafana management utilities.
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

# ------------------------------------------------------------------------------
# Create Grafana data-sources using the Grafana rest endpoints.
# ------------------------------------------------------------------------------
function create_grafana_datasources() {
  local json_files fqdn
  json_files="$GRAFANA_HOME/customization/datasources/*.json"
  fqdn=$(hostname -f)


  printf "%s | [INFO]  creating Grafana data-sources...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        GRAFANA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_PORT: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PORT"
  printf "%s | [DEBUG]          json_files: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$json_files"
  printf "%s | [DEBUG]        GRAFANA_USER: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_USER"
  printf "%s | [DEBUG]    GRAFANA_PASSWORD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PASSWORD"
  printf "%s | [DEBUG]    GRAFANA_PROTOCOL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROTOCOL"
  printf "%s | [DEBUG]                FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"

  start_grafana
  for file in $json_files; do
    printf "%s | [DEBUG] applying \"%s\" file...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file"
    curl \
      -X POST \
      -H "Content-Type: application/json" \
      --user "$GRAFANA_USER":"$GRAFANA_PASSWORD" \
      --data-binary @"$file" \
      "$GRAFANA_PROTOCOL://$fqdn:$GRAFANA_PORT/api/datasources"
    printf "\n"
  done;
  stop_grafana
}

# ----------------------------------------------------------------------------
# Grafana server configuration.
# ------------------------------------------------------------------------------
function grafana_configuration() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO]  configuring Grafana...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]             GRAFANA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]             GRAFANA_PORT: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PORT"
  printf "%s | [DEBUG]           GRAFANA_CONFIG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_CONFIG"
  printf "%s | [DEBUG]          GRAFANA_STORAGE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_STORAGE"
  printf "%s | [DEBUG]          GRAFANA_LOG_DIR: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_LOG_DIR"
  printf "%s | [DEBUG]          GRAFANA_PLUGINS: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PLUGINS"
  printf "%s | [DEBUG]     GRAFANA_PROVISIONING: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROVISIONING"
  printf "%s | [DEBUG]                     FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]            KEYSTORE_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]         GRAFANA_PROTOCOL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROTOCOL"

  sed -i "s|\${GRAFANA_STORAGE}|$GRAFANA_STORAGE|g" "$GRAFANA_CONFIG"
  sed -i "s|\${GRAFANA_LOG_DIR}|$GRAFANA_LOG_DIR|g" "$GRAFANA_CONFIG"
  sed -i "s|\${GRAFANA_PLUGINS}|$GRAFANA_PLUGINS|g" "$GRAFANA_CONFIG"
  sed -i "s|\${GRAFANA_PROVISIONING}|$GRAFANA_PROVISIONING|g" "$GRAFANA_CONFIG"
  sed -i "s|\${GRAFANA_PORT}|$GRAFANA_PORT|g" "$GRAFANA_CONFIG"
  sed -i "s|\${FQDN}|$fqdn|g" "$GRAFANA_CONFIG"
  sed -i "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" "$GRAFANA_CONFIG"
  sed -i "s|\${GRAFANA_PROTOCOL}|$GRAFANA_PROTOCOL|g" "$GRAFANA_CONFIG"
}

# ----------------------------------------------------------------------------
# Substitute the placeholders in the config/datasource directory.
# This directory contains Grafana custom data-source definitions.
# ------------------------------------------------------------------------------
function prepare_grafana_datasource_files() {
  local json_files
  json_files="$GRAFANA_HOME/customization/datasources/*.json"

  printf "%s | [INFO]  updating Grafana datasource json files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    PROMETHEUS_HOST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_HOST"
  printf "%s | [DEBUG]         json_files: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$json_files"

  for file in $json_files; do
    printf "%s | [DEBUG]  updating the \"%s\" file...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file"
    sed -i "s|\${PROMETHEUS_HOST}|$PROMETHEUS_HOST|g" "$file"
    sed -i "s|\${PROMETHEUS_PORT}|$PROMETHEUS_PORT|g" "$file"
    sed -i "s|\${PROMETHEUS_PROTOCOL}|$PROMETHEUS_PROTOCOL|g" "$file"
  done
}

# ------------------------------------------------------------------------------
# Start the Grafana Server and wait for the full server start-up.
# ------------------------------------------------------------------------------
function start_grafana() {
  local grafana_log
  grafana_log="$GRAFANA_LOG_DIR/grafana.log"

  printf "%s | [INFO]  starting Grafana...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    GRAFANA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]     grafana_log: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$grafana_log"

  cd "$GRAFANA_HOME"
  ./bin/grafana server 2>&1 &

  tail -n +1 -F "$grafana_log" &
  wait_until_content_found "$grafana_log" "Adding GroupVersion featuretoggle.grafana.app"
  printf "%s | [INFO]  Grafana has been started...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Stop the Grafana Server.
# ------------------------------------------------------------------------------
function stop_grafana() {
  local process_name
  process_name="grafana"

  printf "%s | [INFO]  stopping Grafana...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    process_name: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$process_name"
  pkill "$process_name"
}

# ----------------------------------------------------------------------------
# Set Grafana admin password.
# ------------------------------------------------------------------------------
function update_grafana_password() {
  printf "%s | [INFO]  setting up Grafana password for the 'admin' user...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        GRAFANA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_USER: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_USER"
  printf "%s | [DEBUG]    GRAFANA_PASSWORD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PASSWORD"
  cd "$GRAFANA_HOME"
  ./bin/grafana cli "$GRAFANA_USER" reset-admin-password "$GRAFANA_PASSWORD"
}
