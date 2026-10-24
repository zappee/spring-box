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
# Create a Grafana data source via the Grafana REST API.
# ------------------------------------------------------------------------------
function create_grafana_datasources() {
  local json_files fqdn
  json_files=("$GRAFANA_HOME"/customization/datasources/*.json)
  fqdn=$(hostname -f)


  printf "%s | [INFO]  Creating Grafana data source...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PORT"
  printf "%s | [DEBUG]          json_files: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$json_files"
  printf "%s | [DEBUG]        GRAFANA_USER: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_USER"
  printf "%s | [DEBUG]    GRAFANA_PASSWORD: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PASSWORD"
  printf "%s | [DEBUG]    GRAFANA_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROTOCOL"
  printf "%s | [DEBUG]                FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"

  # Check if any JSON files actually exist
  if [ ! -e "${json_files[0]}" ]; then
    printf "%s | [WARN]  No data source JSON files found.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 1
  fi

  start_grafana
  for file in "${json_files[@]}"; do
    printf "%s | [DEBUG] Applying file: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file"
    curl \
      -X POST \
      -H "Content-Type: application/json" \
      --user "$GRAFANA_USER:$GRAFANA_PASSWORD" \
      --data-binary @"$file" \
      "$GRAFANA_PROTOCOL://$fqdn:$GRAFANA_PORT/api/datasources"
    printf "\n"
  done;
  stop_grafana
}

# ------------------------------------------------------------------------------
# Configure the Grafana server.
# ------------------------------------------------------------------------------
function grafana_configuration() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO]  Configuring Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]             GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]             GRAFANA_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PORT"
  printf "%s | [DEBUG]           GRAFANA_CONFIG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_CONFIG"
  printf "%s | [DEBUG]          GRAFANA_STORAGE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_STORAGE"
  printf "%s | [DEBUG]          GRAFANA_LOG_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_LOG_DIR"
  printf "%s | [DEBUG]          GRAFANA_PLUGINS: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PLUGINS"
  printf "%s | [DEBUG]     GRAFANA_PROVISIONING: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROVISIONING"
  printf "%s | [DEBUG]                     FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]            KEYSTORE_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]         GRAFANA_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROTOCOL"

 # Validate that the configuration file exists before processing
  if [ ! -f "$GRAFANA_CONFIG" ]; then
    printf "%s | [ERROR] Grafana config file not found.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 1
  fi

  sed -i \
    -e "s|\${GRAFANA_STORAGE}|$GRAFANA_STORAGE|g" \
    -e "s|\${GRAFANA_LOG_DIR}|$GRAFANA_LOG_DIR|g" \
    -e "s|\${GRAFANA_PLUGINS}|$GRAFANA_PLUGINS|g" \
    -e "s|\${GRAFANA_PROVISIONING}|$GRAFANA_PROVISIONING|g" \
    -e "s|\${GRAFANA_PORT}|$GRAFANA_PORT|g" \
    -e "s|\${FQDN}|$fqdn|g" \
    -e "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" \
    -e "s|\${GRAFANA_PROTOCOL}|$GRAFANA_PROTOCOL|g" \
    "$GRAFANA_CONFIG"
}

# ------------------------------------------------------------------------------
# Interpolate environment variables into the Grafana data source JSON files.
# ------------------------------------------------------------------------------
function prepare_grafana_datasource_files() {
  local json_files
  json_files=("$GRAFANA_HOME"/customization/datasources/*.json)

  printf "%s | [INFO]  Updating Grafana data source JSON files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        PROMETHEUS_HOST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_HOST"
  printf "%s | [DEBUG]        PROMETHEUS_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_PORT"
  printf "%s | [DEBUG]    PROMETHEUS_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_PROTOCOL"
  printf "%s | [DEBUG]             JSON files: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${json_files[*]}"

  for file in "${json_files[@]}"; do
    printf "%s | [DEBUG] Updating file: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file"
    sed -i \
      -e "s|\${PROMETHEUS_HOST}|$PROMETHEUS_HOST|g" \
      -e "s|\${PROMETHEUS_PORT}|$PROMETHEUS_PORT|g" \
      -e "s|\${PROMETHEUS_PROTOCOL}|$PROMETHEUS_PROTOCOL|g" \
      "$file"
  done
}

# ------------------------------------------------------------------------------
# Start the Grafana server and wait for it to complete initialization.
# ------------------------------------------------------------------------------
function start_grafana() {
  local grafana_log
  grafana_log="$GRAFANA_LOG_DIR/grafana.log"

  printf "%s | [INFO]  Starting Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        Log file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$grafana_log"

  cd "$GRAFANA_HOME" || return 1
  ./bin/grafana server 2>&1 &

  tail -n +1 -F "$grafana_log" &
  wait_until_content_found "$grafana_log" "Adding GroupVersion featuretoggle.grafana.app"
  printf "%s | [INFO]  Grafana server is fully started.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Stop the Grafana server.
# ------------------------------------------------------------------------------
function stop_grafana() {
  local process_name="grafana"

  printf "%s | [INFO]  Stopping Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    Process name: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$process_name"
  if pkill "$process_name"; then
    printf "%s | [INFO]  Grafana server stopped successfully.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [WARN]  No running Grafana server process found.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}

# ------------------------------------------------------------------------------
# Reset the password for the Grafana administrative account.
# ------------------------------------------------------------------------------
function update_grafana_password() {
  printf "%s | [INFO]  Setting up Grafana password for the 'admin' user...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_USER: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_USER"
  printf "%s | [DEBUG]    GRAFANA_PASSWORD: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PASSWORD"

  cd "$GRAFANA_HOME" || return 1
  ./bin/grafana cli "$GRAFANA_USER" reset-admin-password "$GRAFANA_PASSWORD"
}
