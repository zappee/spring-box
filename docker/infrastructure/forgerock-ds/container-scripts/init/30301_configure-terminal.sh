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
{
  printf "export %s=\"%s\"\n" "DS_HOME" "$DS_HOME"
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "ADMIN_CONNECTOR_PORT" "$ADMIN_CONNECTOR_PORT"
  printf "export %s=\"%s\"\n" "LDAP_PORT" "$LDAP_PORT"
  printf "export %s=\"%s\"\n" "LDAPS_PORT" "$LDAPS_PORT"
  printf "export %s=\"%s\"\n" "LDAP_USER_DN" "$LDAP_USER_DN"
  printf "export %s=\"%s\"\n" "LDAP_USER_PASSWORD" "$LDAP_USER_PASSWORD"
  printf "export %s=\"%s\"\n" "DEPLOYMENT_KEY_FILE" "$DEPLOYMENT_KEY_FILE"
  printf "export %s=\"%s\"\n" "DS_CONFIG_BACKUP" "$DS_CONFIG_BACKUP"
  printf "export %s=\"%s\"\n" "AM_IDENTITY_STORE_BACKUP" "$AM_IDENTITY_STORE_BACKUP"
  printf "export %s=\"%s\"\n" "AM_CONFIG_STORE_BACKUP" "$AM_CONFIG_STORE_BACKUP"
  printf "cd %s\n" "$DS_HOME"
} >> /etc/profile
log_end "$0"
