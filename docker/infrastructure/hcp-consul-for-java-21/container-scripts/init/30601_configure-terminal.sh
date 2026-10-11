#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  November 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

log_start "$0"
{
  printf "export %s=\"%s\"\n" "KEYSTORE_HOME" "$KEYSTORE_HOME"
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "CONSUL_CONFIG_DIR" "$CONSUL_CONFIG_DIR"
  printf "export %s=\"%s\"\n" "CONSUL_CONFIG_TEMPLATE_DIR" "$CONSUL_CONFIG_TEMPLATE_DIR"
  printf "export %s=\"%s\"\n" "CONSUL_DATA_DIR" "$CONSUL_DATA_DIR"
} >> /etc/profile
log_end "$0"
