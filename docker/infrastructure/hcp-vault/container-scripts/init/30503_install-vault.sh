#!/bin/bash -ue
# ******************************************************************************
# HashiCorp Vault installation script.
#
# Since: July 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /vault-functions.sh

# ----------------------------------------------------------------------------
# HashiCorp Vault environment preparation.
# ------------------------------------------------------------------------------
function prepare_vault_environment() {
  printf "%s | [INFO]  preparing HashiCorp Vault environment...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                       FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$FQDN"
  printf "%s | [DEBUG]              KEYSTORE_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]    CA_CERTIFICATE_FILENAME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CA_CERTIFICATE_FILENAME"

  printf "%s | [DEBUG] converting certificates to pem format...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  openssl x509 -in "$KEYSTORE_HOME/$FQDN.crt" -out "$KEYSTORE_HOME/$FQDN.pem" -outform PEM
  openssl pkcs8 -in "$KEYSTORE_HOME/$FQDN.key" -passin pass:changeit -out "$KEYSTORE_HOME/$FQDN.key.pem" -outform PEM
  openssl x509 -in "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.crt" -out "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.pem" -outform PEM

  chmod 0644 "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.pem" "$KEYSTORE_HOME/$FQDN.pem"
  chmod 0640 "$KEYSTORE_HOME/$FQDN.key.pem"
}

# ----------------------------------------------------------------------------
# HashiCorp Vault configuration.
#
# Supported log levels: trace, debug, info, warn, and error
# ------------------------------------------------------------------------------
function prepare_vault_config_file() {
  local listening_host
  listening_host="0.0.0.0"
  
  local server_cert_file server_key_file ca_cert_file
  server_cert_file="$KEYSTORE_HOME/$FQDN.pem"
  server_key_file="$KEYSTORE_HOME/$FQDN.key.pem"
  ca_cert_file="$KEYSTORE_HOME/ca.pem"

  printf "%s | [INFO]  preparing HashiCorp Vault config file...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                   config file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CONFIG_FILE"
  printf "%s | [DEBUG]                listening host: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$listening_host"
  printf "%s | [DEBUG]                      api port: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_PORT"
  printf "%s | [DEBUG]      path to vault file store: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FILE_STORE"
  printf "%s | [DEBUG]                     log level: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_LOG_LEVEL"
  printf "%s | [DEBUG]     server public certificate: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$server_cert_file"
  printf "%s | [DEBUG]    server private certificate: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$server_key_file"
  printf "%s | [DEBUG]                CA certificate: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ca_cert_file"

  sed -i "s|\${LISTENING_HOST}|$listening_host|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${API_PORT}|$VAULT_API_PORT|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${SERVER_CERT_FILE}|$server_cert_file|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${SERVER_KEY_FILE}|$server_key_file|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${CA_CERT_FILE}|$ca_cert_file|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${VAULT_FILE_STORE}|$VAULT_FILE_STORE|g" "$VAULT_CONFIG_FILE"
  sed -i "s|\${LOG_LEVEL}|$VAULT_LOG_LEVEL|g" "$VAULT_CONFIG_FILE"
}

# ----------------------------------------------------------------------------
# HashiCorp Vault configuration.
#
# Initializing the audit log.
# ------------------------------------------------------------------------------
function initialize_audit_log() {
  printf "%s | [INFO]  initializing audit log for HashiCorp Vault, logfile: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_AUDIT_LOG"

  local root_token
  root_token=$(get_vault_root_token)

  printf "%s | [DEBUG]      root token: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$root_token"
  VAULT_TOKEN="$root_token" vault audit enable file file_path="$VAULT_AUDIT_LOG"
}

# ----------------------------------------------------------------------------
# HashiCorp Vault configuration.
#
# Supported log levels: trace, debug, info, warn, and error
# ------------------------------------------------------------------------------
function initialize_vault() {
  printf "%s | [INFO]  initializing HashiCorp Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  vault operator init -key-shares=3 -key-threshold=2 > "$VAULT_INIT_LOG"
  printf "%s | [WARN]  take note of these values and store them securely:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  cat "$VAULT_INIT_LOG"
}

# ----------------------------------------------------------------------------
# Initialize HashiCorp Vault key-value secret engine.
# ------------------------------------------------------------------------------
function initializing_kv_engine() {
  printf "%s | [INFO]  initializing the Key-Value secrets engine...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  
  local root_token unseal_key_1 unseal_key_2
  root_token=$(get_vault_root_token)
  unseal_key_1=$(get_vault_unseal_key "1")
  unseal_key_2=$(get_vault_unseal_key "2")

  printf "%s | [DEBUG]      VAULT_ADDR: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"
  printf "%s | [DEBUG]    unseal key 1: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_1"
  printf "%s | [DEBUG]    unseal key 2: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_2"
  printf "%s | [DEBUG]      root token: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$root_token"
  unseal_vault "$unseal_key_1"
  unseal_vault "$unseal_key_2"
  VAULT_TOKEN="$root_token" vault secrets enable -version=2 kv
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"

FQDN=$(hostname -f)
CA_CERTIFICATE_FILENAME="ca"
generate_certificate "server" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.key" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/issued/$FQDN.crt" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/$CA_CERTIFICATE_FILENAME.crt" "$KEYSTORE_HOME"
prepare_vault_environment
prepare_vault_config_file
start_vault 
  initialize_vault
  initializing_kv_engine
  initialize_audit_log
stop_vault
  
log_end "$0"
