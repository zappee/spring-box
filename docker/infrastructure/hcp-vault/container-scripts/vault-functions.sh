#!/bin/bash -ue
# ******************************************************************************
# Hazelcast Vault management utilities.
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
# Extract the HashiCorp Vault Initial Root Token from the log.
#
# Global dependencies
#    VAULT_INIT_LOG: Path to the file containing Vault init log.
# ------------------------------------------------------------------------------
function get_vault_root_token() {
  local root_token
  root_token=$(grep "Initial Root Token" "$VAULT_INIT_LOG" |  awk '{ print $4 }')
  printf "%s" "$root_token"
}

# ------------------------------------------------------------------------------
# Extract a specific HashiCorp Vault Unseal Key from the log.
#
# Arguments:
#    $1: The identifier of the unseal key to retrieve.
#
# Global dependencies
#   mVAULT_INIT_LOG: Path to the file containing Vault init output.
# ------------------------------------------------------------------------------
function get_vault_unseal_key() {
  local key_id key
  key_id="$1"
  key=$(grep "Unseal Key $key_id" "$VAULT_INIT_LOG" |  awk '{ print $4 }')
  printf "%s" "$key"
}

# ------------------------------------------------------------------------------
# Redirect the Vault audit log file contents to standard output.
#
# This function terminates any existing 'tail' processes monitoring the same
# log file before spinning up a new background tail process. This is ideal
# for containerized environments (like Docker) to stream logs to stdout.
#
# Global dependencies
#    VAULT_AUDIT_LOG: Path to the Vault audit log file.
# ------------------------------------------------------------------------------
function redirect_audit_log() {
  VAULT_AUDIT_LOG="${VAULT_AUDIT_LOG:-/vault/logs/vault-audit.log}"
  printf "%s | [INFO ] Redirecting HashiCorp Vault audit log ('%s') to stdout...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_AUDIT_LOG"

  # Count active tail processes before pkill.
  local count_before
  count_before=$(pgrep -f "tail.*${VAULT_AUDIT_LOG}" 2>/dev/null | wc -l)
  printf "%s | [INFO] Found %d active background tail process(es) for audit log before termination.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$count_before"

  pkill -f "tail.*${VAULT_AUDIT_LOG}" 2>/dev/null || true

  # Count active tail processes after pkill.
  local count_after
  count_after=$(pgrep -f "tail.*${VAULT_AUDIT_LOG}" 2>/dev/null | wc -l)
  printf "%s | [INFO] Found %d active background tail process(es) for audit log after termination.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$count_after"

  tail -n +1 -F "$VAULT_AUDIT_LOG" &
}

# ------------------------------------------------------------------------------
# Logs the HashiCorp Vault configuration.
# ------------------------------------------------------------------------------
function log_context() {
  printf "%s | [DEBUG]   --- General --------------------------------------\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                      FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$FQDN"
  printf "%s | [DEBUG]         VAULT_CONFIG_FILE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CONFIG_FILE"
  printf "%s | [DEBUG]          VAULT_FILE_STORE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FILE_STORE"
  printf "%s | [DEBUG]        VAULT_CLUSTER_NAME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CLUSTER_NAME"
  printf "%s | [DEBUG]   --- Log ------------------------------------------\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]           VAULT_LOG_LEVEL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_LOG_LEVEL"
  printf "%s | [DEBUG]            VAULT_INIT_LOG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_INIT_LOG"
  printf "%s | [DEBUG]                 VAULT_LOG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_LOG"
  printf "%s | [DEBUG]           VAULT_AUDIT_LOG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_AUDIT_LOG"
  printf "%s | [DEBUG]   --- Communication --------------------------------\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]            VAULT_TCP_HOST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TCP_HOST"
  printf "%s | [DEBUG]            VAULT_TCP_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TCP_PORT"
  printf "%s | [DEBUG]\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        VAULT_API_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_PROTOCOL"
  printf "%s | [DEBUG]            VAULT_API_HOST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_HOST"
  printf "%s | [DEBUG]            VAULT_API_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_PORT"
  printf "%s | [DEBUG]\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    VAULT_CLUSTER_PROTOCOL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CLUSTER_PROTOCOL"
  printf "%s | [DEBUG]        VAULT_CLUSTER_HOST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CLUSTER_HOST"
  printf "%s | [DEBUG]        VAULT_CLUSTER_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CLUSTER_PORT"
  printf "%s | [DEBUG]   --- Keystore -------------------------------------\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]             KEYSTORE_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$KEYSTORE_HOME"
  printf "%s | [DEBUG]          ROOT_CA_BASENAME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ROOT_CA_BASENAME"
}

# ------------------------------------------------------------------------------
# Start HashiCorp Vault server daemon in the background.
# ------------------------------------------------------------------------------
function start_vault() {
  local fqdn
  fqdn=$(hostname -f)

  # These two environment variables used by the Vault CLI client so it knows how to locate and securely communicate with
  # your Vault server. Every time you run a command like 'vault kv get', 'vault operator init', or 'vault audit enable',
  # the CLI uses VAULT_ADDR to know where the Vault server is listening on the network.
  #
  # VAULT_ADDR
  #   The API endpoint address of your HashiCorp Vault server. E.g. "https://127.0.0.1:8200" or "https://example.com"
  #
  # VAULT_CACERT
  #  Tells the Vault CLI client (or SDK) where to find the CA certificate file on disk so it can trust and verify the
  #  TLS certificate presented by the Vault server.
  export VAULT_ADDR="https://${fqdn}:${VAULT_API_PORT}"
  export VAULT_CACERT="${KEYSTORE_HOME}/${ROOT_CA_BASENAME}.pem"

  printf "%s | [INFO ] Starting HashiCorp Vault server daemon...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                 FQDN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]           VAULT_ADDR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"
  printf "%s | [DEBUG]         VAULT_CACERT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CACERT"
  printf "%s | [DEBUG]    VAULT_CONFIG_FILE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_CONFIG_FILE"
  printf "%s | [DEBUG]            VAULT_LOG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_LOG"
  printf "%s | [DEBUG]       VAULT_API_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_API_PORT"

  vault server -config="${VAULT_CONFIG_FILE}" 2>&1 | tee "${VAULT_LOG}" &
  redirect_audit_log

  printf "%s | [INFO] Waiting for Vault API endpoint to become responsive on port %s...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${VAULT_API_PORT}"
  while ! nc -w 5 127.0.0.1 "$VAULT_API_PORT" 2>/dev/null; do
    sleep 0.5
  done
  printf "%s | [INFO ] HashiCorp Vault has successfully started.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Terminate all running instances of HashiCorp Vault.
#
# This function sends termination signals to any active Vault processes,
# ensuring a clean shutdown of the server daemon.
# ------------------------------------------------------------------------------
function stop_vault() {
  printf "%s | [INFO ] Stopping HashiCorp Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  pkill -q "vault" 2>/dev/null || true
  printf "%s | [INFO ] HashiCorp Vault has been stopped.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Unseal the HashiCorp Vault server.
#
# Vault starts in a sealed state and cannot read decrypted storage backends
# until the threshold of unseal keys has been supplied.
#
# Arguments:
#    $1: The raw Shamir unseal key shard to submit to the server.
# ------------------------------------------------------------------------------
function unseal_vault() {
  local unseal_key="$1"

  printf "%s | [INFO ] Unsealing HashiCorp Vault using key: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$unseal_key"
  vault operator unseal "${unseal_key}"
}
