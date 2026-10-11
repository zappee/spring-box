#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  Aug 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /vault-functions.sh

log_start "$0"

VAULT_TOKEN="$(get_vault_root_token)"
printf "%s | [DEBUG] setting VAULT_TOKEN environment variable to \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$VAULT_TOKEN"
sed -i "s/.*VAULT_TOKEN.*/export VAULT_TOKEN=$VAULT_TOKEN/" /etc/profile

log_end "$0"
