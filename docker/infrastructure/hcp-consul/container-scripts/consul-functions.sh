#!/bin/bash -ue
# ******************************************************************************
# HashiCorp Consul management utilities.
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
# Generates HashiCorp Consul configuration file.
#
# Global dependencies
#    CONSUL_CONFIG_DIR:          Path where consul.configuration file reside.
#    CONSUL_CONFIG_TEMPLATE_DIR: Path to the json template configuration file.
#    CONSUL_DATA_DIR:            Directory designated for Consul data.
#    CONSUL_SERVER_HOSTNAME:     Consul server cluster node.
#    KEYSTORE_HOME:              Root directory holding cryptographic materials.
# ------------------------------------------------------------------------------
function setup_consul() {
  local template_config_file config_file fqdn domain
  template_config_file="$CONSUL_CONFIG_TEMPLATE_DIR/consul-template.json"
  config_file="$CONSUL_CONFIG_DIR/consul.json"
  fqdn=$(hostname -f)
  domain=${fqdn#"${fqdn%.*.*}".}

  local consul_server_host consul_node_name
  consul_server_host=${CONSUL_SERVER_HOSTNAME:-}
  consul_node_name="node-${fqdn}"

  printf "%s | [INFO ] Configuring HashiCorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]      Config directory: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_CONFIG_DIR"
  printf "%s | [DEBUG]       Config template: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$template_config_file"
  printf "%s | [DEBUG]           Config file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$config_file"
  printf "%s | [DEBUG]        Data directory: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_DATA_DIR"
  printf "%s | [DEBUG]             Node name: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_node_name"
  printf "%s | [DEBUG]    Consul server host: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_server_host"
  printf "%s | [DEBUG]         Keystore home: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]                  FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]                Domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"

  mkdir -p "$CONSUL_CONFIG_DIR"
  cp -f "$template_config_file" "$config_file"
  sed -i \
    -e "s|\${CONSUL_DATA_DIR}|$CONSUL_DATA_DIR|g" \
    -e "s|\${CONSUL_NODE_NAME}|$consul_node_name|g" \
    -e "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" \
    -e "s|\${FQDN}|$fqdn|g" \
    -e "s|\${DOMAIN}|$domain|g" \
    "$config_file"
}

# ------------------------------------------------------------------------------
# Start HashiCorp Consul.
# Launches the Consul in the background and loops until the node shows up with
# an active "alive" status footprint in the log.
#
# Global dependencies
#    CONSUL_CONFIG_DIR: Path where consul.json resides.
#    CONSUL_DATA_DIR:   Directory designated for Consul data.
# ------------------------------------------------------------------------------
function start_consul() {
  local fqdn consul_node_name
  fqdn=$(hostname -f)
  consul_node_name="node-${fqdn}"

  printf "%s | [INFO ] Starting HashiCorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    Node name:        '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_node_name"
  printf "%s | [DEBUG]    Config directory: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_CONFIG_DIR"
  printf "%s | [DEBUG]    Data directory:   '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_DATA_DIR"

  consul agent \
    -bind=0.0.0.0 \
    -config-dir="$CONSUL_CONFIG_DIR" \
    -data-dir="$CONSUL_DATA_DIR" &

  while ! consul members 2>/dev/null | grep -E "${consul_node_name}.*alive" -q; do
    printf "%s | [DEBUG] Consul is not ready yet, waiting...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    sleep 0.5
  done

  printf "%s | [INFO ] HashiCorp Consul has been started successfully.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
