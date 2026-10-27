#!/bin/bash -ue
# ******************************************************************************
# Backup ForgeRock Access Management Server configuration prior to container
# shutdown.

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
# Backup the ForgeRock Access Management Server configuration files.
# ------------------------------------------------------------------------------
function backup_am_config() {
  local timestamp backup_file
  timestamp="$(date "+%Y-%m-%d_%H.%M.%S")"
  backup_file="$AM_HOME/backup/am-config-files_$timestamp.tar.gz"

  printf "%s | [INFO]  backing up ForgeRock Access Management Server configuration...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  tar \
    -C "$(dirname "$AM_HOME")" \
    --exclude backup \
    --exclude var/debug \
    --exclude var/audit \
    --exclude var/stats* \
    -zcvf "$backup_file" "$(basename "$AM_HOME")"

  printf "%s | [DEBUG] server configuration backup file: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$backup_file"
  printf "%s | [INFO]  configuration files has been backed up\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"
if [ "$AM_CONFIG_BACKUP" == "true" ]; then
  stop_tomcat
  backup_am_config
fi
log_end "$0"
