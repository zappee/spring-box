#!/bin/bash -ue
# ******************************************************************************
# Hazelcast Platform management utilities.
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
# Generates Hazelcast Platform configuration file.
#
# Global dependencies
#    HAZELCAST_HOME:                Root installation path of Hazelcast.
#    HAZELCAST_CONFIG_TEMPLATE_DIR: Directory containing the config file templates.
#    HAZELCAST_CLUSTER_NAME:        Hazelcast cluster identification name.
# ------------------------------------------------------------------------------
function setup_hazelcast() {
  local hazelcast_config="hazelcast.xml"
  local fqdn keystore_file keystore_password
  fqdn=$(hostname -f)
  keystore_file="/tmp/$fqdn.p12"
  keystore_password="changeit"

  printf "%s | [INFO ] Configuring Hazelcast Platform...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                   HAZELCAST_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HAZELCAST_HOME"
  printf "%s | [DEBUG]    HAZELCAST_CONFIG_TEMPLATE_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HAZELCAST_CONFIG_TEMPLATE_DIR"
  printf "%s | [DEBUG]                      Config file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HAZELCAST_HOME/config/$hazelcast_config"
  printf "%s | [DEBUG]                             FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]                    Keystore path: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_file"
  printf "%s | [DEBUG]                Keystore password: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_password"

  cp -f "$HAZELCAST_CONFIG_TEMPLATE_DIR/$hazelcast_config" "$HAZELCAST_HOME/config/"
  sed -i \
    -e "s|\${HAZELCAST_CLUSTER_NAME}|$HAZELCAST_CLUSTER_NAME|g" \
    -e "s|\${KEYSTORE_FILE}|$keystore_file|g" \
    -e "s|\${KEYSTORE_PASSWORD}|$keystore_password|g" \
    "$HAZELCAST_HOME/config/$hazelcast_config"
}

# ----------------------------------------------------------------------------
# Launches the Hazelcast Platform node in the background and monitors the
# log until a successful initialization state is found.
#
# Global dependencies
#    HAZELCAST_HOME: Root installation path of Hazelcast.
# ------------------------------------------------------------------------------
function start_hazelcast() {
  printf "%s | [INFO ] Starting Hazelcast Platform...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    HAZELCAST_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HAZELCAST_HOME"

  "$HAZELCAST_HOME"/bin/hz start &
  wait_until_content_found "$HAZELCAST_HOME/logs/hazelcast.log" "is STARTED"
}
