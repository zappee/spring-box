#!/bin/bash -e
# ******************************************************************************
# Functions that sets a key/value in Vault.
#
# Usage:
#    $ set-value.sh <key> <value> [debug]
#    
#    parameter 1: key
#    parameter 2: value
#    parameter 3: optional, if 'debug' is used then detailed log will be shown
#
# Example:
#   $ set-value.sh "com.remal.host.pki" "com.remal.pki" debug
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
  if [[ ! ( "$#" -eq 3 && "$3" == "debug") ]]; then
    return 1
  else
    return 0
  fi
}

# ----------------------------------------------------------------------------
# Validate the user's input parameters.
# ------------------------------------------------------------------------------
function user_input_validation() {
  if [[ ! ( "$#" -eq 3 && "$3" == "debug" || "$#" -eq 2 ) ]]; then
    printf "Illegal number of parameters.\n"
    printf "Usage: set-value.sh <key> <value> [debug]\n"
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

if [ "$VAULT_PATH" = "." ]; then printf "%s | [ERROR] path can't be blank, must contain at least one dot (.) character\n" "$(date +"%Y-%m-%d %H:%M:%S")"; exit 1; fi
 
if is_debug "$@"; then printf "%s | [DEBUG] setting a value to Vault...\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
if is_debug "$@"; then printf "%s | [DEBUG]            key=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"; fi
if is_debug "$@"; then printf "%s | [DEBUG]          value=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$2"; fi
if is_debug "$@"; then printf "%s | [DEBUG]     VAULT_ADDR=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_ADDR"; fi
if is_debug "$@"; then printf "%s | [DEBUG]    VAULT_TOKEN=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"; fi
if is_debug "$@"; then printf "%s | [DEBUG]     VAULT_PATH=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_PATH"; fi
if is_debug "$@"; then printf "%s | [DEBUG]    VAULT_FIELD=\"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_FIELD"; fi

if vault kv get "kv/$VAULT_PATH" >/dev/null 2>&1; then
  if is_debug "$@"; then printf "%s | [DEBUG] PATCH will be run\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
  vault kv patch "kv/$VAULT_PATH" "$VAULT_FIELD=$2"
else
  if is_debug "$@"; then printf "%s | [DEBUG] PUT will be run\n" "$(date +"%Y-%m-%d %H:%M:%S")"; fi
  vault kv put "kv/$VAULT_PATH" "$VAULT_FIELD=$2"
fi
