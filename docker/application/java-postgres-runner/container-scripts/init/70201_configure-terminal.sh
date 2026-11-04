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

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
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
