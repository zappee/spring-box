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

# ----------------------------------------------------------------------------
# Returns true if debug mode if used.
# ------------------------------------------------------------------------------
function is_debug() {
  if [[ ! ( "$#" -eq 2 && "$2" == "debug") ]]; then
    return 1
  else
    return 0
  fi
}

# ----------------------------------------------------------------------------
# Validate the user's input parameters.
# ------------------------------------------------------------------------------
function user_input_validation() {
  if [[ ! ( "$#" -eq 2 && "$2" == "debug" || "$#" -eq 1 ) ]]; then
    printf "Illegal number of parameters.\n"
    printf "Usage: get-value.sh <key> [debug]\n"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
user_input_validation "$@"

FULL_PATH="${1//.///}"
VAULT_FIELD="$(basename "$FULL_PATH")"
VAULT_PATH="$(dirname "$FULL_PATH")"

if is_debug "$@"; then printf "%s | [DEBUG] getting value from Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
if is_debug "$@"; then printf "%s | [DEBUG]            key=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"; fi
if is_debug "$@"; then printf "%s | [DEBUG]     VAULT_ADDR=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"; fi
if is_debug "$@"; then printf "%s | [DEBUG]    VAULT_TOKEN=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"; fi
if is_debug "$@"; then printf "%s | [DEBUG]     VAULT_PATH=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_PATH"; fi
if is_debug "$@"; then printf "%s | [DEBUG]    VAULT_FIELD=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FIELD"; fi

vault kv get -field="$VAULT_FIELD" "kv/$VAULT_PATH"
