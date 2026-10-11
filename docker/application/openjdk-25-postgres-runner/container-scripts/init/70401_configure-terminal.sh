#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  March 2026
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

log_start "$0"

{
  printf "export %s=\"%s\"\n" "POSTGRES_HOME" "$POSTGRES_HOME"
  printf "export %s=\"%s\"\n" "POSTGRES_DATA" "$POSTGRES_DATA"
  printf "export %s=\"%s\"\n" "POSTGRES_LOG_DIR" "$POSTGRES_LOG_DIR"
  printf "export %s=\"%s\"\n" "POSTGRES_CONFIG" "$POSTGRES_CONFIG"
  printf "export %s=\"%s\"\n" "DB_ADMIN_USER" "$DB_ADMIN_USER"
  printf "export %s=\"%s\"\n" "DB_ADMIN_PASSWORD" "$DB_ADMIN_PASSWORD"
  printf "export %s=\"%s\"\n" "DB_APP_DATABASE" "$DB_APP_DATABASE"
  printf "export %s=\"%s\"\n" "DB_APP_USER" "$DB_APP_USER"
  printf "export %s=\"%s\"\n" "DB_APP_PASSWORD" "$DB_APP_PASSWORD"
} >> /etc/profile

log_end "$0"
