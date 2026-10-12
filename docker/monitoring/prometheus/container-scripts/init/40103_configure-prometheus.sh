#!/bin/bash -ue
# ******************************************************************************
# Prometheus configuration.
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

# ----------------------------------------------------------------------------
# Prometheus server SSL configuration for the web console.
# ------------------------------------------------------------------------------
function configure_server_ssl() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO]  configuring Prometheus to use SSL (HTTPS) for the web console...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    PROMETHEUS_WEB_CONFIG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_WEB_CONFIG"
  printf "%s | [DEBUG]                     FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]            KEYSTORE_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"

  sed -i "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" "$PROMETHEUS_WEB_CONFIG"
  sed -i "s|\${FQDN}|$fqdn|g" "$PROMETHEUS_WEB_CONFIG"
}

# ----------------------------------------------------------------------------
# Set up scrape_configs of the Prometheus server.
# A scrape_config section specifies a set of targets and parameters describing
# how to scrape them.
# ------------------------------------------------------------------------------
function configure_scrape() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO]  configuring how Prometheus scrapes targets...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    PROMETHEUS_CONFIG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PROMETHEUS_CONFIG"
  printf "%s | [DEBUG]          CONSUL_HOST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_HOST"
  printf "%s | [DEBUG]                 FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]        KEYSTORE_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"

  sed -i "s|\${CONSUL_HOST}|$CONSUL_HOST|g" "$PROMETHEUS_CONFIG"
  sed -i "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" "$PROMETHEUS_CONFIG"
  sed -i "s|\${FQDN}|$fqdn|g" "$PROMETHEUS_CONFIG"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
configure_server_ssl
configure_scrape
log_end "$0"
