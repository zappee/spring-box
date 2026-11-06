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
# Global dependencies
#    FQDN:             Fully Qualified Domain Name of the host.
#    KEYSTORE_HOME:    Directory path containing the certificates.
#    ROOT_CA_BASENAME: Base filename of the CA certificate.
#    openssl:          CLI tool used for cryptographic conversions.
# ------------------------------------------------------------------------------
function prepare_vault_environment() {
  printf "%s | [INFO ] Preparing HashiCorp Vault environment...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$FQDN"
  printf "%s | [DEBUG]       KEYSTORE_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]    ROOT_CA_BASENAME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ROOT_CA_BASENAME"
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
    -in "$KEYSTORE_HOME/$ROOT_CA_BASENAME.crt" \
    -out "$KEYSTORE_HOME/$ROOT_CA_BASENAME.pem" \
    -outform PEM

  printf "%s | [DEBUG] Updating the key permissions...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  chmod 0644 "$KEYSTORE_HOME/$ROOT_CA_BASENAME.pem" "$KEYSTORE_HOME/$FQDN.pem"
  chmod 0640 "$KEYSTORE_HOME/$FQDN.key.pem"
}

# ------------------------------------------------------------------------------
# Configures the HashiCorp Vault configuration file by replacing template placeholders.
# Supported log levels: trace, debug, info, warn, and error
# ------------------------------------------------------------------------------
function prepare_vault_config_file() {
  local tls_cert_file tls_key_file tls_ca_file
  tls_cert_file="${KEYSTORE_HOME}/${FQDN}.pem"
  tls_key_file="${KEYSTORE_HOME}/${FQDN}.key.pem"
  tls_ca_file="${KEYSTORE_HOME}/${ROOT_CA_BASENAME}.pem"

  printf "%s | [INFO ] Updating HashiCorp Vault config file...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  log_context

  sed -i \
    -e "s|\${VAULT_CLUSTER_NAME}|$VAULT_CLUSTER_NAME|g" \
    -e "s|\${VAULT_CLUSTER_PROTOCOL}|$VAULT_CLUSTER_PROTOCOL|g" \
    -e "s|\${VAULT_CLUSTER_HOST}|$VAULT_CLUSTER_HOST|g" \
    -e "s|\${VAULT_CLUSTER_PORT}|$VAULT_CLUSTER_PORT|g" \
    -e "s|\${VAULT_API_PROTOCOL}|$VAULT_API_PROTOCOL|g" \
    -e "s|\${VAULT_API_HOST}|$VAULT_API_HOST|g" \
    -e "s|\${VAULT_API_PORT}|$VAULT_API_PORT|g" \
    -e "s|\${VAULT_TCP_HOST}|$VAULT_TCP_HOST|g" \
    -e "s|\${VAULT_TCP_PORT}|$VAULT_TCP_PORT|g" \
    -e "s|\${VAULT_LOG_LEVEL}|$VAULT_LOG_LEVEL|g" \
    -e "s|\${VAULT_FILE_STORE}|$VAULT_FILE_STORE|g" \
    -e "s|\${TLS_CERT_FILE}|$tls_cert_file|g" \
    -e "s|\${TLS_KEY_FILE}|$tls_key_file|g" \
    -e "s|\${TLS_CA_FILE}|$tls_ca_file|g" \
    "$VAULT_CONFIG_FILE"
}

# ------------------------------------------------------------------------------
# Enabling audit log for HashiCorp Vault.
#
# Global dependencies
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
# Global dependencies
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
# Global dependencies
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
  printf "%s | [DEBUG]    Unseal Key-1: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_1"
  printf "%s | [DEBUG]    Unseal Key-2: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key_2"
  printf "%s | [DEBUG]      Root Token: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$root_token"
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
generate_certificate "server" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.key" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/issued/$FQDN.crt" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/$ROOT_CA_BASENAME.crt" "$KEYSTORE_HOME"

prepare_vault_environment
prepare_vault_config_file

start_vault
initialize_vault
initializing_kv_engine
initialize_audit_log
stop_vault

log_end "$0"
