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
# Add a Grafana data source using the HTTP API. No restart required.
# ------------------------------------------------------------------------------
function add_grafana_data_sources() {
  printf "%s | [INFO ] Adding a new Grafana data source...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    PROMETHEUS_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_PROTOCOL"
  printf "%s | [DEBUG]        PROMETHEUS_HOST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_HOST"
  printf "%s | [DEBUG]        PROMETHEUS_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_PORT"

  curl -f -X POST "${GRAFANA_PROTOCOL}://${GRAFANA_USER}:${GRAFANA_PASSWORD}@localhost:${GRAFANA_PORT}/api/datasources" \
    -H "Content-Type: application/json" \
    -d "{
      \"uid\": \"adinoft2gf56of\",
      \"name\": \"${PROMETHEUS_HOST}\",
      \"type\": \"prometheus\",
      \"access\": \"proxy\",
      \"url\": \"${PROMETHEUS_PROTOCOL}://${PROMETHEUS_HOST}:${PROMETHEUS_PORT}\",
      \"basicAuth\": false,
      \"isDefault\": true,
      \"jsonData\": {
        \"httpMethod\": \"POST\",
        \"tlsSkipVerify\": true,
        \"timeInterval\": \"1s\"
      }
    }"

  if [ $? -eq 0 ]; then
    printf "%s | [INFO ] Grafana data source has been successfully added.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [ERROR] Failed to add Grafana data source.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Configure the Grafana server.
# ------------------------------------------------------------------------------
function configuring_grafana() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO ] Configuring Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                    GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]           GRAFANA_CUSTOM_CONFIG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_CUSTOM_CONFIG"
  printf "%s | [DEBUG]                            FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]                 GRAFANA_STORAGE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_STORAGE"
  printf "%s | [DEBUG]                 GRAFANA_LOG_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_LOG_DIR"
  printf "%s | [DEBUG]             GRAFANA_PLUGINS_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PLUGINS_DIR"
  printf "%s | [DEBUG]            GRAFANA_PROVISIONING: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROVISIONING"
  printf "%s | [DEBUG]                GRAFANA_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PROTOCOL"
  printf "%s | [DEBUG]                    GRAFANA_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PORT"
  printf "%s | [DEBUG]                   KEYSTORE_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]    GRAFANA_IMAGE_RENDERER_TOKEN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_IMAGE_RENDERER_TOKEN"
  printf "%s | [DEBUG]     GRAFANA_IMAGE_RENDERER_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_IMAGE_RENDERER_PORT"

 # Validate that the configuration file exists before processing
  if [ ! -f "$GRAFANA_CUSTOM_CONFIG" ]; then
    printf "%s | [ERROR] Grafana custom config file not found.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 0
  fi

  sed -i \
    -e "s|\${FQDN}|$fqdn|g" \
    -e "s|\${GRAFANA_STORAGE}|$GRAFANA_STORAGE|g" \
    -e "s|\${GRAFANA_LOG_DIR}|$GRAFANA_LOG_DIR|g" \
    -e "s|\${GRAFANA_PLUGINS_DIR}|$GRAFANA_PLUGINS_DIR|g" \
    -e "s|\${GRAFANA_PROVISIONING}|$GRAFANA_PROVISIONING|g" \
    -e "s|\${GRAFANA_PROTOCOL}|$GRAFANA_PROTOCOL|g" \
    -e "s|\${GRAFANA_PORT}|$GRAFANA_PORT|g" \
    -e "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" \
    -e "s|\${GRAFANA_IMAGE_RENDERER_TOKEN}|$GRAFANA_IMAGE_RENDERER_TOKEN|g" \
    -e "s|\${GRAFANA_IMAGE_RENDERER_PORT}|$GRAFANA_IMAGE_RENDERER_PORT|g" \
    "$GRAFANA_CUSTOM_CONFIG"

  printf "%s | [INFO ] Grafana server configured.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Configure the Grafana Image Renderer service.
#
# This function is especially important when upgrading the
# grafana-image-renderer binary to a new version, because release files
# downloaded from GitHub (https://github.com/grafana/grafana-image-renderer/releases)
# do not have the executable permission flag set by default.
# ------------------------------------------------------------------------------
function configuring_grafana_image_renderer() {
  printf "%s | [INFO ] Configuring Grafana Image Renderer...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                  GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]    GRAFANA_IMAGE_RENDERER_BIN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_IMAGE_RENDERER_BIN"

  chmod +x "${GRAFANA_HOME}/bin/${GRAFANA_IMAGE_RENDERER_BIN}"
}

# ------------------------------------------------------------------------------
# Add a '1s' refresh interval option to Grafana dashboards.
#
# By default, the smallest refresh interval available in the Grafana UI is 5s.
# This adds a 1s interval option strictly for testing purposes.
# ------------------------------------------------------------------------------
function configuring_grafana_interval() {
  printf "%s | [INFO ] Configuring Grafana refresh interval for dashboards...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"

  grep -rl '"5s","10s","30s"' "$GRAFANA_HOME/public/build/" | xargs -r -t sed -i 's/"5s","10s","30s"/"1s","5s","10s","30s"/g'
}

# ------------------------------------------------------------------------------
# Start the Grafana server and wait for it to complete initialization.
# ------------------------------------------------------------------------------
function start_grafana() {
  local grafana_log
  grafana_log="$GRAFANA_LOG_DIR/grafana.log"

  printf "%s | [INFO ] Starting Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        Log file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$grafana_log"

  "${GRAFANA_HOME}/bin/grafana" server --homepath "${GRAFANA_HOME}" 2>&1 &
  tail -n +1 -F "$grafana_log" &

  # Unfortunately Grafana’s '/api/health' endpoint only checks if the core
  # process is alive and if the primary database is reachable. However, the
  # Grafana API routing engine and plugins take a few additional seconds to
  # fully initialize and begin accepting dynamic data source modifications.
  #
  # Parsing Grafana's logs is a highly reliable way to overcome this condition.
  #
  # wait_for_http_status_code "TRUE" "${GRAFANA_PROTOCOL}://localhost:${GRAFANA_PORT}/api/health" "200"
  wait_until_content_found "$grafana_log" "HTTP Server Listen"

  printf "%s | [INFO ] Grafana server is fully started.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Install Grafana Image Renderer service.
#
# Test the renderer:
#    curl -H "X-Auth-Token: secret-render-token" "http://localhost:8081/render?url=https://localhost:3000/login" -o /tmp/test.png
# ------------------------------------------------------------------------------
function start_grafana_image_renderer() {
  local grafana_renderer_log
  grafana_renderer_log="$GRAFANA_LOG_DIR/grafana-renderer.log"

  printf "%s | [INFO ] Starting Grafana Image Renderer...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                      GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_IMAGE_RENDERER_BIN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_IMAGE_RENDERER_BIN"
  printf "%s | [DEBUG]      GRAFANA_IMAGE_RENDERER_TOKEN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_IMAGE_RENDERER_TOKEN"
  printf "%s | [DEBUG]                   GRAFANA_LOG_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_LOG_DIR"
  printf "%s | [DEBUG]    Grafana-Image-Renderer logfile: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$grafana_renderer_log"

  "${GRAFANA_HOME}/bin/${GRAFANA_IMAGE_RENDERER_BIN}" \
    server \
    --browser.path=/usr/bin/chromium-browser \
    --browser.flag="--ignore-certificate-errors" \
    --server.auth-token="${GRAFANA_IMAGE_RENDERER_TOKEN}" > "${grafana_renderer_log}" 2>&1 &

  tail -n +1 -F "${grafana_renderer_log}" &

  if [ $? -eq 0 ]; then
    printf "%s | [INFO ] Grafana Image Renderer has been successfully started.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [ERROR] Failed to start Grafana Image Renderer.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Stop the Grafana server.
# ------------------------------------------------------------------------------
function stop_grafana() {
  local process_name="grafana"

  printf "%s | [INFO ] Stopping Grafana server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    Process name: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$process_name"
  if pkill "$process_name"; then
    printf "%s | [INFO ] Grafana server stopped successfully.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [WARN ] No running Grafana server process found.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}

# ------------------------------------------------------------------------------
# Reset the password for the Grafana administrative account.
# ------------------------------------------------------------------------------
function update_grafana_password() {
  printf "%s | [INFO ] Setting up Grafana password for the 'admin' user...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        GRAFANA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_HOME"
  printf "%s | [DEBUG]        GRAFANA_USER: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_USER"
  printf "%s | [DEBUG]    GRAFANA_PASSWORD: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$GRAFANA_PASSWORD"

  cd "$GRAFANA_HOME" || return 1
  ./bin/grafana cli "$GRAFANA_USER" reset-admin-password "$GRAFANA_PASSWORD"

  printf "%s | [INFO ] Grafana admin credentials updated.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
