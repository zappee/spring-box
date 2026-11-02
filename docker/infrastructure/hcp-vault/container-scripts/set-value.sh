#!/bin/bash -e
# ******************************************************************************
# Functions to store a key-value pair in HashiCorp Vault.
#
# Usage:
#   set-value.sh <key> <value> [debug]
#
# Arguments:
#   <key>     The specific key path to update or create in Vault.
#   <value>   The value to assign to the key.
#   [debug]   Optional. If set to 'debug', verbose logs will be displayed.
#
# Example:
#   $ set-value.sh "com.remal.crm.customer-auto-registration" "true" debug
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
#    $2: Vault field string.
#    $3: Mode indicator string (evaluated for "debug").
# ------------------------------------------------------------------------------
function is_debug() {
  if [[ ! ( "$#" -eq 3 && "$3" == "debug") ]]; then
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
#    $2: Value to set.
#    $3: Execution mode configuration string (optional, accepts "debug").
# ------------------------------------------------------------------------------
function user_input_validation() {
  if [[ ! ( ("$#" -eq 3 && "$3" == "debug") || "$#" -eq 2 ) ]]; then
    printf "[ERROR] Illegal number of parameters.\n"
    printf "Usage: set-value.sh <key> <value> [debug]\n"
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

if [ "$VAULT_PATH" = "." ]; then
  printf "%s | [ERROR] Key path must contain at least one dot (.) character.\n" "$(date +"%Y-%m-%d %H:%M:%S")";
  printf "%s | [ERROR] Example: set-value.sh my-app.prod db_password supersecret\n" "$(date +"%Y-%m-%d %H:%M:%S")";
  exit 1;
fi

if is_debug "$@"; then
  printf "%s | [DEBUG] Adding a key/value to Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]            Key: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"
  printf "%s | [DEBUG]          Value: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$2"
  printf "%s | [DEBUG]     VAULT_ADDR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"
  printf "%s | [DEBUG]    VAULT_TOKEN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"
  printf "%s | [DEBUG]     VAULT_PATH: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_PATH"
  printf "%s | [DEBUG]    VAULT_FIELD: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FIELD"
fi

if vault kv get "kv/$VAULT_PATH" >/dev/null 2>&1; then
  if is_debug "$@"; then printf "%s | [DEBUG] Calling a PATCH operation...\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
  vault kv patch "kv/$VAULT_PATH" "$VAULT_FIELD=$2"
else
  if is_debug "$@"; then printf "%s | [DEBUG] Calling a PUT operation...\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
  vault kv put "kv/$VAULT_PATH" "$VAULT_FIELD=$2"
fi
