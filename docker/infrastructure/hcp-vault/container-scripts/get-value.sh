#!/bin/bash -e
# ******************************************************************************
# Functions to retrieve the value of a given key from HashiCorp Vault.
#
# Usage:
#   get-value.sh <key> [debug]
#
# Arguments:
#   <key>     The specific key path to retrieve from Vault.
#   [debug]   Optional. If set to 'debug', verbose logs will be displayed.
#
# Example:
#   get-value.sh "com.remal.crm.customer-auto-registration"
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

# ------------------------------------------------------------------------------
# Evaluates whether debug mode is active based on passed arguments.
#
# Arguments:
#    $1: Parameters passes to the script.
#    $2: Mode indicator string (evaluated for "debug").
# ------------------------------------------------------------------------------
function is_debug() {
  if [[ ! ( "$#" -eq 2 && "$2" == "debug") ]]; then
    return 1
  else
    return 0
  fi
}

# ------------------------------------------------------------------------------
# Validates the execution parameters.
#
# Arguments:
#    $1: Key name to look up.
#    $2: Execution mode configuration string (optional, accepts "debug").
# ------------------------------------------------------------------------------
function user_input_validation() {
  if [[ ! ( ("$#" -eq 2 && "$2" == "debug") || "$#" -eq 1 ) ]]; then
    printf "[ERROR] Illegal number of parameters.\n"
    printf "Usage: get-value.sh <key> [debug]\n"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
user_input_validation "$@"

FULL_PATH="${1//./\/}"
VAULT_FIELD="$(basename "$FULL_PATH")"
VAULT_PATH="$(dirname "$FULL_PATH")"

if is_debug "$@"; then
  printf "%s | [DEBUG] Getting value from Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]            Key: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"
  printf "%s | [DEBUG]     VAULT_ADDR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"
  printf "%s | [DEBUG]    VAULT_TOKEN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"
  printf "%s | [DEBUG]     VAULT_PATH: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_PATH"
  printf "%s | [DEBUG]    VAULT_FIELD; '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FIELD"
fi

vault kv get -field="$VAULT_FIELD" "kv/$VAULT_PATH"
