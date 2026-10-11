#!/bin/bash -ue
# ******************************************************************************
# Functions that helps to manage HashiCorp Consul.
#
# Since:  March 2026
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ----------------------------------------------------------------------------
# Configure the HashiCorp Consul.
# It generates the Consul configuration file.
# ------------------------------------------------------------------------------
function setup_consul() {
  local template_config_file config_file fqdn domain
  template_config_file="$CONSUL_CONFIG_TEMPLATE_DIR/consul-template.json"
  config_file="$CONSUL_CONFIG_DIR/consul.json"
  fqdn=$(hostname -f)
  domain=${fqdn#"${fqdn%.*.*}".}

  local consul_server_host consul_node_name
  consul_server_host=${CONSUL_SERVER_HOSTNAME:-}
  consul_node_name="node-$fqdn"

  printf "%s | [INFO]  setting up HashiCorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]      config directory: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_CONFIG_DIR"
  printf "%s | [DEBUG]       config template: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$template_config_file"
  printf "%s | [DEBUG]           config file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$config_file"
  printf "%s | [DEBUG]        data directory: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_DATA_DIR"
  printf "%s | [DEBUG]             node name: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_node_name"
  printf "%s | [DEBUG]    consul server host: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_server_host"
  printf "%s | [DEBUG]         keystore home: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]                  fqdn: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]                domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"

  mkdir -p "$CONSUL_CONFIG_DIR"
  cp -f "$template_config_file" "$config_file"
  sed -i "s|\${CONSUL_DATA_DIR}|$CONSUL_DATA_DIR|g" "$config_file"
  sed -i "s|\${CONSUL_NODE_NAME}|$consul_node_name|g" "$config_file"
  sed -i "s|\${CONSUL_SERVER_HOSTNAME}|$consul_server_host|g" "$config_file"
  sed -i "s|\${KEYSTORE_HOME}|$KEYSTORE_HOME|g" "$config_file"
  sed -i "s|\${FQDN}|$fqdn|g" "$config_file"
  sed -i "s|\${DOMAIN}|$domain|g" "$config_file"
}

# ----------------------------------------------------------------------------
# Start HashiCorp Consul.
# ------------------------------------------------------------------------------
function start_consul() {
  local fqdn consul_node_name
  fqdn=$(hostname -f)
  consul_node_name="node-$fqdn"

  printf "%s | [INFO]  starting HashiCorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    node name:        \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$consul_node_name"
  printf "%s | [DEBUG]    config directory: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_CONFIG_DIR"
  printf "%s | [DEBUG]    data directory:   \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_DATA_DIR"

  consul agent \
    -bind=0.0.0.0 \
    -config-dir="$CONSUL_CONFIG_DIR" \
    -data-dir="$CONSUL_DATA_DIR" &

  while [ "$(consul members 2>/dev/null | awk "/$consul_node_name/ && /alive/" | wc -l)" -ne 1 ]; do
    printf "%s | [DEBUG] consul is not running, waiting...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    sleep 0.5
  done

  printf "%s | [INFO]  HashiCorp Consul has been started\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
