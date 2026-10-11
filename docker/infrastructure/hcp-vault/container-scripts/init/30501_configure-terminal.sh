#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
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
