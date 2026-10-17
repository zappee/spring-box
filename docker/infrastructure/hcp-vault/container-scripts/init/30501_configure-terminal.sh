#!/bin/bash -ue
# ******************************************************************************
# Bash environment setup for a Docker container.
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

log_start "$0"

FQDN=$(hostname -f)
{
  printf "export %s=\"%s\"\n" "KEYSTORE_HOME" "$KEYSTORE_HOME"
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "VAULT_ADDR" "https://$FQDN:$VAULT_API_PORT"
  printf "export %s=\"%s\"\n" "VAULT_TOKEN" "not-set-yet"
  printf "export %s=\"%s\"\n" "VAULT_API_PORT" "$VAULT_API_PORT"
  printf "export %s=\"%s\"\n" "VAULT_CACERT" "$KEYSTORE_HOME/ca.pem"
  printf "export %s=\"%s\"\n" "VAULT_CONFIG_FILE" "$VAULT_CONFIG_FILE"
  printf "export %s=\"%s\"\n" "VAULT_INIT_LOG" "$VAULT_INIT_LOG"
} >> /etc/profile

log_end "$0"
