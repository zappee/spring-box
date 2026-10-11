#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

log_start "$0"
{
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "KEYSTORE_HOME" "$KEYSTORE_HOME"
  printf "export %s=\"%s\"\n" "CONSUL_HOST" "$CONSUL_HOST"
  printf "export %s=\"%s\"\n" "PROMETHEUS_HOME" "$PROMETHEUS_HOME"
  printf "export %s=\"%s\"\n" "FQDN" "$(hostname -f)"
  printf "cd %s\n" "$PROMETHEUS_HOME"
} >> /etc/profile
log_end "$0"
