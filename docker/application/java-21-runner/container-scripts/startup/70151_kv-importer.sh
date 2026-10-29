#!/bin/bash -ue
# ******************************************************************************
# Imports key-value pairs from a properties file into HashiCorp Consul. It reads
# the config.properties file during container startup and adds any missing
# key-value pairs into HashiCorp Consul.
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
# Verifies the existence of a required file. If the specified file is missing,
# logs a warning message and terminates the script.
#
# Arguments:
#    $1: Path to the file that must exist
# ------------------------------------------------------------------------------
file_exists() {
  local file_to_check
  file_to_check="$1"

  if [ ! -f "$file_to_check" ]; then
    printf "%s | [WARN ] File '%s' not found.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_check"
    log_end "$0"
    exit 0
  else
    printf "%s | [DEBUG] File '%s' exists.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_check"
  fi
}

# ------------------------------------------------------------------------------
# Removes temporary workspace directories and files to clean up disk space.
#
# Arguments:
#    $1: Absolute path to the workspace directory to delete
# ------------------------------------------------------------------------------
cleanup_workspace() {
  local workspace_home
  workspace_home="$1"

  printf "%s | [INFO ] Cleaning up the workspace: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$workspace_home"
  rm -R "$workspace_home"
}

# ------------------------------------------------------------------------------
# Extracts specific files from a ZIP archive into a target directory.
#
# Arguments:
#    $1: Path to the source ZIP archive file
#    $2: Path to the destination directory for extraction
#    $3: Optional; First specific file path to extract from the ZIP
#    $4: Optional; Second specific file path to extract from the ZIP
# ------------------------------------------------------------------------------
extract_file() {
  local archive_file target_dir fie_to_extract_1 fie_to_extract_2
  archive_file="$1"
  target_dir="$2"
  fie_to_extract_1="${3:-}"
  fie_to_extract_2="${4:-}"

  printf "%s | [INFO ] Extracting files from the archive...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]           archive file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$archive_file"
  printf "%s | [DEBUG]             target dir: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$target_dir"
  printf "%s | [DEBUG]    1st file to extract: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1"
  printf "%s | [DEBUG]    2nd file to extract: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_2"

  if [ -z "$archive_file" ]; then
    printf "%s | [WARN ] No archive file specified. Skipping extraction.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    # Executing "docker stop" followed by "docker start" can leave stale files from the previous run.
    # To ensure a clean state, the destination directory is cleared prior to extraction.
    printf "%s | [DEBUG] Removing previous contents from the '%s' directory...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${target_dir}"
    rm -rf "${target_dir:?}"/*

 # Suppress and bypass exit code 11 which indicates that no matching files were found in the archive.
  # Refer to the standard unzip manual for complete exit code specifications:
  # https://die.net

    # Ignore the exit code 11 that appears if the file to extract not found in the ZIP.
    # See the full exit code list here: https://linux.die.net/man/1/unzip.
    # Check if file_to_extract_2 is EMPTY (-z).
    if [[ -z "${fie_to_extract_2-}"  ]]; then
      printf "%s | [DEBUG] Unpacking '%s' from '%s' to '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1" "$archive_file" "$target_dir"
      unzip -j "$archive_file" "$fie_to_extract_1" -d "$target_dir" || (exit "$(($? == 11 ? 0 : $?))")
    else
      printf "%s | [DEBUG] Unpacking '%s' and '%s' files from '%s' to '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1" "$fie_to_extract_2" "$archive_file" "$target_dir"
      unzip -j "$archive_file" "$fie_to_extract_1" "$fie_to_extract_2" -d "$target_dir" || (exit "$(($? == 11 ? 0 : $?))")
    fi
  fi
}

# ------------------------------------------------------------------------------
# Determines the base Key-Value (KV) context path for HashiCorp Consul.
#
# The context path in the Consul KV starts with the literal prefix "config/",
# followed by the application name. The configuration prioritizes the property
# 'spring.cloud.consul.config.name' if defined; otherwise, it falls back to
# 'spring.application.name'.
#
# For example, if:
#   - reference in Java code to the key: @Value("${app.hello}")
#   - application.properties:  spring.application.name=welcome-service
#   Then the full path of the key is: config/welcome-service/app.hello
#
# Arguments:
#    $1: Path to the Spring configuration properties file
#    $2: Return value, the resolved context path
# ------------------------------------------------------------------------------
get_kv_context() {
  local properties_file application_name config_name key_context
  properties_file="$1"
  application_name=$( (grep -w "^spring.application.name" | cut -d'=' -f2) < "$properties_file")
  config_name=$( (grep -w "^spring.cloud.consul.config.name" | cut -d'=' -f2) < "$properties_file")
  key_context="config/"

  if [[ -n "$config_name" ]]; then
    key_context+="$config_name"
  else
    key_context+="$application_name"
  fi

  local return_var="$2"
  printf -v "$return_var" "%s" "$key_context"
}

# ------------------------------------------------------------------------------
# Identifies the single JAR file located within the specified directory.
#
# Arguments:
#    $1: Path to the target directory containing the JAR file
#    $2: Return value, the resolved file path
# ------------------------------------------------------------------------------
get_first_jar() {
  local jars_home
  jars_home="$1"

  printf "%s | [INFO ] Searching for a JAR file in the '%s' directory...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jars_home"

  local -a files
  mapfile -d '' files < <(find "$jars_home" -type f -name "*.jar" -print0)

  local number_of_files
  number_of_files=${#files[@]}
  printf "%s | [DEBUG] Found %d file(s) in the directory.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$number_of_files"

  if [[ "$number_of_files" -eq 0 ]]; then
    printf "%s | [WARN ] No *.jar files found in the directory.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  elif [[ "$number_of_files" -gt 1 ]]; then
    printf "%s | [ERROR] Ambiguous configuration: multiple JAR files found:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s\n" "${files[@]}"
    exit 1
  fi

 # Assign the single found JAR file to the provided return variable
  local return_var="$2"
  printf -v "$return_var" "%s" "${files[0]}"
}

# ------------------------------------------------------------------------------
# Inserts missing Key-Value (KV) pairs into the HashiCorp Consul KV store.
#
# Reads a standard properties file line-by-line, skips empty spaces or comments,
# and checks each key against Consul. If the key does not exist, it inserts it.
#
# Arguments:
#    $1: Path to the *.properties configuration file
#    $2: Base key context prefix inside the Consul KV store
# ------------------------------------------------------------------------------
insert_kv() {
  local properties_file key_context key value
  properties_file="$1"
  key_context="$2"

  # Read file line-by-line,
  # handling cases where the last line lacks a trailing newline
  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    # Skip empty lines, whitespace, or comments starting with '#'
    [[ "$key" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue

    # Trim leading/trailing whitespace if necessary
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    local full_key
    full_key="${key_context}/${key}"

    if ! consul_key_exists "$full_key"; then
      consul_put_key "$full_key" "$value"
    fi
  done < "$properties_file"
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"
printf "%s | [INFO ] Inserting Key-Value pairs into HashiCorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

UNPACK_DIR="/tmp/extracted-jar"
PATH_TO_PROP_FILE="BOOT-INF/classes"
APP_PROP_FILE="application.properties"
KV_PROP_FILE="config.properties"

get_first_jar "$JAR_HOME" JAR_FILE

extract_file "$JAR_FILE" "$UNPACK_DIR" "$PATH_TO_PROP_FILE/$APP_PROP_FILE"
file_exists "$UNPACK_DIR/$APP_PROP_FILE"

extract_file "$JAR_FILE" "$UNPACK_DIR" "$PATH_TO_PROP_FILE/$APP_PROP_FILE" "$PATH_TO_PROP_FILE/$KV_PROP_FILE"
file_exists "$UNPACK_DIR/$KV_PROP_FILE"

get_kv_context "$UNPACK_DIR/$APP_PROP_FILE" CONTEXT
insert_kv "$UNPACK_DIR/$KV_PROP_FILE" "$CONTEXT"
cleanup_workspace "$UNPACK_DIR"

log_end "$0"
