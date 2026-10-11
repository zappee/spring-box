#!/bin/bash -ue
# ******************************************************************************
# Restore ForgeRock Access Management configuration files.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /tomcat-functions.sh

# ------------------------------------------------------------------------------
# Restore the ForgeRock Access Management configuration from a backup file.
# ------------------------------------------------------------------------------
function restore_am_config() {
  local backup_file
  
  if [[ "latest" == "${1,,}" ]]; then
    printf "%s | [INFO]  restoring server configuration from the latest backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file=$(get_latest_file "$AM_HOME/backup" "am-config-files_????-??-??_??.??.??.tar.gz")
  else
    printf "%s | [INFO]  restoring server configuration from a specific backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file="$AM_HOME/backup/$1"
  fi
  printf "%s | [DEBUG] backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  
  if [[ -f "$backup_file" ]]; then
    stop_tomcat
    printf "%s | [INFO]  restoring the configuration files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    tar -xvf "$backup_file" -C "$(dirname "$AM_HOME")"
    printf "%s | [INFO]  server configuration files has been overwritten\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    start_tomcat
  else
    printf "%s | [WARN]  the provided backup file does not exist: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  fi
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
if [ -n "$AM_CONFIG_RESTORE_FROM" ]; then restore_am_config "$AM_CONFIG_RESTORE_FROM"; fi
log_end "$0"
