#!/bin/bash -ue
# ******************************************************************************
# ForgeRock Directory Server management functions.
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

# ------------------------------------------------------------------------------
# Backup the ForgeRock Directory Server configuration files.
# ------------------------------------------------------------------------------
function backup_ds_config() {
  local is_running timestamp backup_file
  is_running=$(get_ds_server_state)
  timestamp="$(date "+%Y-%m-%d_%H.%M.%S")"
  backup_file="$DS_HOME/backup/ds-config-files_$timestamp.tar.gz"

  printf "%s | [INFO]  backing up ForgeRock Directory Server configuration...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  if [ "$is_running" == "true" ]; then
    stop_ds
  fi

  tar -czvf "$backup_file" --directory="$DS_HOME" config/

  printf "%s | [DEBUG] server configuration backup file: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  printf "%s | [INFO]  configuration files has been backed up\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Backup LDAP data.
#
# Parameters:
#    param 1: backend name, for example: 'am-config', 'am-identity-store'
# ------------------------------------------------------------------------------
function backup_ds_data() {
  printf "%s | [INFO]  backing up ForgeRock Directory Server LDAP database...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

  local backend_name is_running fqdn timestamp backup_file
  backend_name="$1"
  is_running=$(get_ds_server_state)
  fqdn=$(hostname -f)
  timestamp="$(date "+%Y-%m-%d_%H.%M.%S")"
  backup_file="${DS_HOME}/backup/${backend_name}-ldap_${timestamp}.tar.gz"

  # the keystore can bu used as a truststore because it contains the CA certificate too
  local keystore_file keystore_password
  keystore_file="/tmp/$fqdn.p12"
  keystore_password="changeit"

  printf "%s | [DEBUG]   directory service home: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$DS_HOME"
  printf "%s | [DEBUG]                 hostname: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]             backend name: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backend_name"
  printf "%s | [DEBUG]              backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  printf "%s | [DEBUG]             ldap user DN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$LDAP_USER_DN"
  printf "%s | [DEBUG]       ldap user password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$LDAP_USER_PASSWORD"
  printf "%s | [DEBUG]     admin connector port: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ADMIN_CONNECTOR_PORT"
  printf "%s | [DEBUG]            keystore file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_file"
  printf "%s | [DEBUG]        keystore password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_password"

  if [ "$is_running" == "false" ]; then
    start_ds
  fi

  rm -rf "$DS_HOME"/bak/*
  "$DS_HOME/bin/dsbackup" create \
    --hostname "$fqdn" \
    --port "$ADMIN_CONNECTOR_PORT" \
    --bindDN "$LDAP_USER_DN" \
    --bindPassword "$LDAP_USER_PASSWORD" \
    --backendName "$backend_name" \
    --backupLocation "$DS_HOME/bak" \
    --no-prompt \
    --usePkcs12KeyStore "$keystore_file" \
    --keyStorePassword "$keystore_password" \
    --certNickname "$fqdn" \
    --usePkcs12TrustStore "$keystore_file" \
    --trustStorePassword "$keystore_password"

  tar -czvf "$backup_file" --directory="$DS_HOME" bak/
  printf "%s | [INFO]  LDAP database has been backed up\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Get the sate of the ForgeRock Directory Server.
# If the server is running then returns with true otherwise with false.
# ------------------------------------------------------------------------------
function get_ds_server_state() {
  local fqdn
  fqdn=$(hostname -f)

  "$DS_HOME/bin/status" \
      --hostname "$fqdn" \
      --port "$ADMIN_CONNECTOR_PORT" \
      --bindDn "$LDAP_USER_DN" \
      --bindPassword "$LDAP_USER_PASSWORD" \
      --trustAll \
      > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    printf "true"
  else
    printf "false"
  fi
}

# ------------------------------------------------------------------------------
# Restore the ForgeRock Directory Server configuration from a backup file.
# ------------------------------------------------------------------------------
function restore_ds_config() {
  local backup_file
  
  if [[ "latest" == "${1,,}" ]]; then
    printf "%s | [INFO]  restoring server configuration from the latest backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file=$(get_latest_file "$DS_HOME/backup" "ds-config-files_????-??-??_??.??.??.tar.gz")
  else
    printf "%s | [INFO]  restoring server configuration from a specific backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file="$DS_HOME/backup/$1"
  fi
  printf "%s | [DEBUG] backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  
  if [[ -f "$backup_file" ]]; then
    stop_ds
    tar -xvf "$backup_file" -C "$DS_HOME"
    printf "%s | [INFO]  server configuration has been restored\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [WARN]  the provided backup file does not exist: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  fi
}

# ------------------------------------------------------------------------------
# Restore LDAP data from a backup file.
#
# Parameters:
#    param 1: backup file
#    param 2: backend name, for example: 'am-config', 'am-identity-store'
# ------------------------------------------------------------------------------
function restore_ds_data() {
  local backup_from backend_name fqdn backup_file
  backup_from="$1"
  backend_name="$2"
  fqdn=$(hostname -f)

  # the keystore cen bu used as a truststore too because it contains the CA certificate as well
  local keystore_file keystore_password
  keystore_file="/tmp/$fqdn.p12"
  keystore_password="changeit"
  
  if [[ "latest" == "${backup_from,,}" ]]; then
    printf "%s | [INFO]  restoring the LDAP database from the latest backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file=$(get_latest_file "$DS_HOME/backup" "${backend_name}-ldap_????-??-??_??.??.??.tar.gz")
  else
    printf "%s | [INFO]  restoring the LDAP database from a specific backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file="$DS_HOME/backup/$backup_from"
  fi
  printf "%s | [DEBUG] backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"

  if [[ -f "$backup_file" ]]; then
    printf "%s | [DEBUG]   directory service home: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$DS_HOME"
    printf "%s | [DEBUG]              backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
    printf "%s | [DEBUG]             ldap user DN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$LDAP_USER_DN"
    printf "%s | [DEBUG]       ldap user password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$LDAP_USER_PASSWORD"
    printf "%s | [DEBUG]                 hostname: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
    printf "%s | [DEBUG]     admin connector port: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$ADMIN_CONNECTOR_PORT"
    printf "%s | [DEBUG]            keystore file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_file"
    printf "%s | [DEBUG]        keystore password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_password"
    start_ds
    printf "%s | [DEBUG] unpacking the backup files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    tar -xvf "$backup_file" -C "$DS_HOME"
    "$DS_HOME/bin/dsbackup" restore \
            --hostname "$fqdn" \
            --port "$ADMIN_CONNECTOR_PORT" \
            --bindDN "$LDAP_USER_DN" \
            --bindPassword "$LDAP_USER_PASSWORD" \
            --backendName "$backend_name" \
            --backupLocation "$DS_HOME/bak" \
            --no-prompt \
            --usePkcs12KeyStore "$keystore_file" \
            --keyStorePassword "$keystore_password" \
            --certNickname "$fqdn" \
            --usePkcs12TrustStore "$keystore_file" \
            --trustStorePassword "$keystore_password"
    printf "%s | [INFO]  LDAP database has been restored\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [WARN]  the provided backup file does not exist: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  fi
}

# ------------------------------------------------------------------------------
# Start the ForgeRock Directory Server.
# ------------------------------------------------------------------------------
function start_ds() {
  if [ "$(get_ds_server_state)" == "false" ]; then
    printf "%s | [DEBUG] removing previous lock files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    rm -vf "$DS_HOME"/locks/*
    printf "%s | [INFO]  starting the LDAP server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    "$DS_HOME/bin/start-ds"
  fi
}

# ------------------------------------------------------------------------------
# Stop the ForgeRock Directory Server.
# ------------------------------------------------------------------------------
function stop_ds() {
  if [ "$(get_ds_server_state)" == "true" ]; then
    "$DS_HOME/bin/stop-ds"
  else
    printf "%s | [INFO]  LDAP server stopped\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}
