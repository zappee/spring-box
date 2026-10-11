#!/bin/bash -e
# ******************************************************************************
# Functions that gets the value of a given key from Vault.
#
# Usage:
#    $ get-value.sh <key> [debug]
#    
#    parameter 1: key
#    parameter 2: optional, if 'debug' is used then detailed log will be shown
#
# Example:
#   $ get-value.sh "com.remal.host.pki"
#
# Since:  August 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
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
# Main program starts here.
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
