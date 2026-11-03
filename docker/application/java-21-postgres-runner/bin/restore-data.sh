#!/bin/bash -ue
# ******************************************************************************
# Restore PostgreSQL database Docker volumes.
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
# Restore a docker volume.
# ------------------------------------------------------------------------------
function restore_docker_volume() {
  local volume_name dir
  volume_name="$1"
  dir="${BACKUP_HOME}/postgres-data/${volume_name}"

 if [ -d "$dir" ]; then
    local filename
    filename=$(ls -t "$dir" | head -n 1)

    if [ -f "${dir}/${filename}" ]; then
      local base_filename data_file labels_file
      base_filename="${filename%%.*}"
      data_file="${base_filename}.tar.gz"
      labels_file="${base_filename}.json"

      local color_info="\e[38;5;226m"
      local color_default="\033[0m"
      printf "%b*******************************************************************************\n" "$color_info"
      printf "** Restoring PostgreSQL data using a Docker volume...\n"
      printf "**    volume:      %s\n" "$volume_name"
      printf "**    backup-dir:  %s\n" "$dir"
      printf "**    data-file:   %s\n" "$data_file"
      printf "**    labels-file: %s\n" "$labels_file"
      printf "*******************************************************************************%b\n" "$color_default"

      # create a Docker volume with labels
      local labels=()
      while IFS=$'\t' read -r key value; do
        labels+=(--label "$key=$value")
      done < <(cat "${dir}/${labels_file}" | jq -r 'to_entries[] | "\(.key)\t\(.value)"')
      docker volume create "$volume_name" "${labels[@]}"

      # open a shell, navigate into the volume directory, and extract the backup file located in the backup directory.
      docker run --rm \
        --volume "$volume_name":/volume \
        --volume "$dir":/backup \
        busybox sh -c "cd /volume && tar xzf /backup/$data_file"

      printf "%b%s%b\n\n" "$color_info" "done" "$color_default"
    fi
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
VOLUMES=("service-1_data" "service-2_data")

for volume in "${VOLUMES[@]}"; do
    restore_docker_volume "$volume"
done
