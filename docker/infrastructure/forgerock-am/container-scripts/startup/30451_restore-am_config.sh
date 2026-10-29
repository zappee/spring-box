#!/bin/bash -ue
# ******************************************************************************
# Restore ForgeRock Access Management configuration files from a backup file.
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
. /tomcat-functions.sh

# ------------------------------------------------------------------------------
# Restore the ForgeRock Access Management configuration from a backup file.
# ------------------------------------------------------------------------------
function restore_am_config() {
  local backup_file
  
  if [[ "latest" == "${1,,}" ]]; then
    printf "%s | [INFO ] restoring server configuration from the latest backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file=$(get_latest_file "$AM_HOME/backup" "am-config-files_????-??-??_??.??.??.tar.gz")
  else
    printf "%s | [INFO ] restoring server configuration from a specific backup...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    backup_file="$AM_HOME/backup/$1"
  fi
  printf "%s | [DEBUG] backup file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  
  if [[ -f "$backup_file" ]]; then
    stop_tomcat
    printf "%s | [INFO ] restoring the configuration files...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    tar -xvf "$backup_file" -C "$(dirname "$AM_HOME")"
    printf "%s | [INFO ] server configuration files has been overwritten\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    start_tomcat
  else
    printf "%s | [WARN ] the provided backup file does not exist: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"
if [ -n "$AM_CONFIG_RESTORE_FROM" ]; then restore_am_config "$AM_CONFIG_RESTORE_FROM"; fi
log_end "$0"
