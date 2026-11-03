#!/bin/bash -ue
# ******************************************************************************
# HashiCorp Vault installation.
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
. /vault-functions.sh

# ------------------------------------------------------------------------------
# Prepares the HashiCorp Vault environment.
#
# Global dependencies:
#    FQDN:                    Fully Qualified Domain Name of the host.
#    KEYSTORE_HOME:           Directory path containing the certificates.
#    CA_CERTIFICATE_FILENAME: Base filename of the CA certificate.
#    openssl:                 CLI tool used for cryptographic conversions.
# ------------------------------------------------------------------------------
function prepare_vault_environment() {
  printf "%s | [INFO ] Preparing HashiCorp Vault environment...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                       FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$FQDN"
  printf "%s | [DEBUG]              KEYSTORE_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]    CA_CERTIFICATE_FILENAME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CA_CERTIFICATE_FILENAME"
  printf "%s | [DEBUG] Converting certificates and private keys to PEM format...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

  printf "%s | [DEBUG] Converting public certificate to PEM format...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  openssl x509 \
    -in "$KEYSTORE_HOME/$FQDN.crt" \
    -out "$KEYSTORE_HOME/$FQDN.pem" \
    -outform PEM

  printf "%s | [DEBUG] Convert password-protected private keys using the PKCS#8 standard to PEM private key....\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  openssl pkcs8 \
    -in "$KEYSTORE_HOME/$FQDN.key" \
    -passin pass:changeit \
    -out "$KEYSTORE_HOME/$FQDN.key.pem" \
    -outform PEM

  printf "%s | [DEBUG] Converting CA certificate to PEM format...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  openssl x509 \
    -in "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.crt" \
    -out "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.pem" \
    -outform PEM

  printf "%s | [DEBUG] Updating the key permissions...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  chmod 0644 "$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.pem" "$KEYSTORE_HOME/$FQDN.pem"
  chmod 0640 "$KEYSTORE_HOME/$FQDN.key.pem"
}

# ------------------------------------------------------------------------------
# Configures the HashiCorp Vault configuration file by replacing template placeholders.
# Supported log levels: trace, debug, info, warn, and error
#
# Global dependencies:
#    $KEYSTORE_HOME:     Directory path containing the certificates.
#    $FQDN:              Fully Qualified Domain Name of the host.
#    $VAULT_CONFIG_FILE: Path to the Vault configuration file.
#    $VAULT_API_PORT:    Network port for the Vault API.
#    $VAULT_FILE_STORE:  Storage directory path for Vault.
#    $VAULT_LOG_LEVEL:   Logging level.
#    sed:                Stream editor used for template string replacement.
# ------------------------------------------------------------------------------
function prepare_vault_config_file() {
  local listening_host="0.0.0.0"
  
  local server_cert_file server_key_file ca_cert_file
  server_cert_file="$KEYSTORE_HOME/$FQDN.pem"
  server_key_file="$KEYSTORE_HOME/$FQDN.key.pem"
  ca_cert_file="$KEYSTORE_HOME/$CA_CERTIFICATE_FILENAME.pem"

  printf "%s | [INFO ] Updating HashiCorp Vault config file...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                   Config file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CONFIG_FILE"
  printf "%s | [DEBUG]                Listening host: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$listening_host"
  printf "%s | [DEBUG]                      API port: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_PORT"
  printf "%s | [DEBUG]      Path to Vault file store: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FILE_STORE"
  printf "%s | [DEBUG]                     Log level: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_LOG_LEVEL"
  printf "%s | [DEBUG]     Server public certificate: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$server_cert_file"
  printf "%s | [DEBUG]    Server private certificate: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$server_key_file"
  printf "%s | [DEBUG]                CA certificate: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ca_cert_file"

  sed -i \
    -e "s|\${LISTENING_HOST}|$listening_host|g" \
    -e "s|\${API_PORT}|$VAULT_API_PORT|g" \
    -e "s|\${SERVER_CERT_FILE}|$server_cert_file|g" \
    -e "s|\${SERVER_KEY_FILE}|$server_key_file|g" \
    -e "s|\${CA_CERT_FILE}|$ca_cert_file|g" \
    -e "s|\${VAULT_FILE_STORE}|$VAULT_FILE_STORE|g" \
    -e "s|\${LOG_LEVEL}|$VAULT_LOG_LEVEL|g" \
    "$VAULT_CONFIG_FILE"
}

# ------------------------------------------------------------------------------
# Enabling audit log for HashiCorp Vault.
#
# Global dependencies:
#    VAULT_AUDIT_LOG: File path where Vault audit logs will be written.
#    vault:           HashiCorp Vault CLI binary executable.
# ------------------------------------------------------------------------------
function initialize_audit_log() {
  printf "%s | [INFO ] Enabling audit log for HashiCorp Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [INFO ]    VAULT_AUDIT_LOG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_AUDIT_LOG"

  local root_token
  root_token=$(get_vault_root_token)

  printf "%s | [DEBUG] Root token: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$root_token"
  VAULT_TOKEN="$root_token" vault audit enable file file_path="$VAULT_AUDIT_LOG"
}

# ------------------------------------------------------------------------------
# Initializes the HashiCorp Vault cluster.
#
# Global dependencies:
#    VAULT_INIT_LOG: File path where initialization keys and root token are saved.
#    vault:          HashiCorp Vault CLI binary executable.
# ------------------------------------------------------------------------------
function initialize_vault() {
  printf "%s | [INFO ] Initializing HashiCorp Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

  # Prevent overwriting an existing init log and accidental re-initialization attempts on an already active cluster.
  if vault operator init -status >/dev/null 2>&1; then
    printf "%s | [INFO ] Vault is already initialized. Skipping initialization step.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    return 0
  fi

  vault operator init -key-shares=3 -key-threshold=2 > "$VAULT_INIT_LOG"
  printf "%s | [WARN ] Take note of these values and store them securely:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  cat "$VAULT_INIT_LOG"
}

# ------------------------------------------------------------------------------
# Initializes the HashiCorp Vault Key-Value (KV) version 2 engine.
#
# Global dependencies:
#    VAULT_ADDR: Vault server API address.
#    vault:      HashiCorp Vault CLI binary executable.
# ------------------------------------------------------------------------------
function initializing_kv_engine() {
  printf "%s | [INFO ] Initializing the HashiCorp Vault Key-Value engine...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  
  local root_token unseal_key_1 unseal_key_2
  root_token=$(get_vault_root_token)
  unseal_key_1=$(get_vault_unseal_key "1")
  unseal_key_2=$(get_vault_unseal_key "2")

  printf "%s | [DEBUG]      VAULT_ADDR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"
  printf "%s | [DEBUG]    Unseal key 1: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_1"
  printf "%s | [DEBUG]    Unseal key 2: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_2"
  printf "%s | [DEBUG]      Root token: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$root_token"
  unseal_vault "$unseal_key_1"
  unseal_vault "$unseal_key_2"

  printf "%s | [DEBUG] Enabling a fresh Key-Value (KV) Version 2 Secrets Engine at the default path kv/ using the Root token...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  VAULT_TOKEN="$root_token" vault secrets enable -version=2 kv
}

# ------------------------------------------------------------------------------
# Main program execution.
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
