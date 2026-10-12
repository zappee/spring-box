#!/bin/bash -ue
# ******************************************************************************
# Back up PostgreSQL database Docker volumes.
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
BACKUP_HOME=$HOME/backup

# ------------------------------------------------------------------------------
# Backup a docker volume.
# ------------------------------------------------------------------------------
function backup_docker_volume() {
  local volume_name dir timestamp filename
  volume_name="$1"
  dir="${BACKUP_HOME}/postgres-data/${volume_name}"
  timestamp=$(date +"%Y-%m-%d_%Hh%Mm%Ss")
  filename="${volume_name}_${timestamp}"

  local color_info="\e[38;5;226m"
  local color_error="\e[38;5;202m"
  local color_default="\033[0m"

  if [ -z "$(docker volume ls -q -f name=^"${volume_name}"$)" ]; then
    printf "%b*******************************************************************************\n" "$color_error"
    printf "** ERROR: DOCKER VOLUME DOES NOT EXISTS\n"
    printf "**    volume: %s\n" "$volume_name"
    printf "*******************************************************************************%b\n" "$color_default"
  else
    printf "%b*******************************************************************************\n" "$color_info"
    printf "** backing up a Docker volume...\n"
    printf "**    volume:      %s\n" "$volume_name"
    printf "**    backup-dir:  %s\n" "$dir"
    printf "**    backup-file: %s\n" "$filename"
    printf "*******************************************************************************%b\n" "$color_default"

    mkdir -p "$dir"

    # backup volume's data
    docker run --rm \
      --volume "$volume_name":/volume \
      --volume "$dir":/backup \
      busybox \
      tar --exclude='postmaster.pid' -zcvf "/backup/${filename}.tar.gz" -C /volume .

    # backup volume's labels
    docker inspect "$volume_name" -f "{{json .Labels}}" > "${dir}/${filename}.json"

    printf "%bdone: %s%b\n\n" "$color_info" "$volume_name" "$color_default"
  fi
  printf "\n"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
VOLUMES=("service-1_data" "service-2_data")

for volume in "${VOLUMES[@]}"; do
    backup_docker_volume "$volume"
done
