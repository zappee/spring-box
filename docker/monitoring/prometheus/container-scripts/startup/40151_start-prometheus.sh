#!/bin/bash -ue
# ******************************************************************************
# Prometheus startup script.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ------------------------------------------------------------------------------
# Start the Prometheus Server and wait for the full server start-up.
# ------------------------------------------------------------------------------
function start_prometheus() {
  printf "%s | [INFO]  starting Prometheus...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]          PROMETHEUS_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_HOME"
  printf "%s | [DEBUG]        PROMETHEUS_CONFIG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_CONFIG"
  printf "%s | [DEBUG]           PROMETHEUS_LOG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_LOG"
  printf "%s | [DEBUG]       PROMETHEUS_STORAGE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_STORAGE"
  printf "%s | [DEBUG]    PROMETHEUS_WEB_CONFIG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_WEB_CONFIG"

  "${PROMETHEUS_HOME}/prometheus" \
      --log.level=debug \
      --config.file="$PROMETHEUS_CONFIG" \
      --web.config.file="$PROMETHEUS_WEB_CONFIG" \
      --storage.tsdb.path="$PROMETHEUS_STORAGE" > "$PROMETHEUS_LOG" 2>&1 &

  tail -n +1 -F "$PROMETHEUS_LOG" &
  wait_until_content_found "$PROMETHEUS_LOG" "Server is ready to receive web requests"
  printf "%s | [INFO]  Prometheus has been started...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
start_prometheus
log_end "$0"
