#!/bin/bash -ue
# ******************************************************************************
# HashiCorp Vault startup script.
#
# Since: July 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /vault-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"

start_vault
unseal_vault "$(get_vault_unseal_key "1")"
unseal_vault "$(get_vault_unseal_key "2")"

log_end "$0"
