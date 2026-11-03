#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
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
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"

printf "%s | [DEBUG] Setting VAULT_TOKEN environment variable...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
VAULT_TOKEN="$(get_vault_root_token)"
printf "%s | [DEBUG] VAULT_TOKEN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"
sed -i "s/.*VAULT_TOKEN.*/export VAULT_TOKEN=$VAULT_TOKEN/" /etc/profile

log_end "$0"
