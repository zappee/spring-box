#!/bin/bash -ue
# ******************************************************************************
# Imports key-value pairs from a properties file into HashiCorp Consul.
# It reads the config.properties file during container startup and adds any
# missing key-value pairs into HashiCorp Consul.
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
# Checks if the provided files exist or not.
# If the files doe not exist then it exits from the script.
#
# Parameters:
#    param 1: path to the file that must exists
# ------------------------------------------------------------------------------
file_exists() {
  local file_to_check
  file_to_check="$1"

  if [ ! -f "$file_to_check" ]; then
    printf "%s | [WARN]  file \"%s\" not found\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_check"
    log_end "$0"
    exit 0
  else
    printf "%s | [DEBUG] file \"%s\" has been successfully extracted\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_check"
  fi
}

# ------------------------------------------------------------------------------
# Clean up the temporary files.
#
# Parameters:
#    param 1: the workspace directory
# ------------------------------------------------------------------------------
cleanup_workspace() {
  local workspace_home
  workspace_home="$1"

  printf "%s | [INFO]  cleaning up the workspace: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$workspace_home"
  rm -R "$workspace_home"
}

# ------------------------------------------------------------------------------
# Unpack the given file(s) from the ZIP.
#
# Parameters:
#    param 1: source zip file
#    param 2: target directory to extract the file
#    param 3: file-1 to extract from the ZIP
#    param 4: file-2 to extract from the ZIP
# ------------------------------------------------------------------------------
extract_file() {
  local archive_file target_dir fie_to_extract_1 fie_to_extract_2
  archive_file="$1"
  target_dir="$2"
  fie_to_extract_1="${3:-}"
  fie_to_extract_2="${4:-}"

  printf "%s | [INFO]  extracting files from an archived content...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        archive file: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$archive_file"
  printf "%s | [DEBUG]          target dir: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$target_dir"
  printf "%s | [DEBUG]    fie-1 to extract: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1"
  printf "%s | [DEBUG]    fie-2 to extract: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_2"

  if [ -z "$archive_file" ]; then
    printf "%s | [WARN]  there is nothing to unpack\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    # Executing "docker stop" then "docker start" can cause an issue the extracted files from the previous run.
    # Therefore, it is best to reset the directory before each run.
    printf "%s | [DEBUG] removing the previous content from the \"%s\" directory...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${target_dir}"
    rm -rf "${target_dir:?}"/*

    # Ignore a specific exit code that appears if the file to extract not found in the ZIP.
    # Exit codes (see the full list here: https://linux.die.net/man/1/unzip):
    #     9: the specified zip files were not found
    #    11: no matching files were found
    if [[ -z "${fie_to_extract_2-}"  ]]; then
      printf "%s | [DEBUG] unpacking \"%s\" and \"%s\" files from \"%s\" to \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1" "$fie_to_extract_2" "$archive_file" "$target_dir"
      unzip -j "$archive_file" "$fie_to_extract_1" -d "$target_dir" || (exit "$(($? == 11 ? 0 : $?))")
    else
      printf "%s | [DEBUG] unpacking the \"%s\" and \"%s\" files from \"%s\" to \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fie_to_extract_1" "$fie_to_extract_2" "$archive_file" "$target_dir"
      unzip -j "$archive_file" "$fie_to_extract_1" "$fie_to_extract_2" -d "$target_dir" || (exit "$(($? == 11 ? 0 : $?))")
    fi
  fi
}

# ------------------------------------------------------------------------------
# Get the key context for the Hashicorp Consul KV store.
# The property key in the Consul KV store should always start with “config” name
# followed by application main class name (spring.application.name). The main
# class name can be overwritten by the spring.cloud.consul.config.name setting.
#
# For example, if
#       - java code: @Value("${app.hello}")
#       - application.properties: spring.application.name=welcome-service
#    then the full path of the key is config/welcome-service/app.hello
#
# Parameters:
#    param 1: property file
#    param 2: variable to hold the return value
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

  local result
  result="$2"
  eval "$result"="${key_context}"
}

# ------------------------------------------------------------------------------
# Get the first JAR file from the given directory.
#
# Parameters:
#    param 1: the directory
#    return:  the firs *.jar file from the directory
# ------------------------------------------------------------------------------
get_first_jar() {
  local jars_home
  jars_home="$1"

  printf "%s | [INFO]  getting the first JAR file from \"%s\" directory...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jars_home"

  local -a files
  mapfile -d '' files < <(find "$jars_home" -type f -name "*.jar" -print0)

  local number_of_files
  number_of_files=${#files[@]}
  printf "%s | [DEBUG] found %s file(s) in the \"%s\" directory\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$number_of_files" "$jars_home"

  if [[ "$number_of_files" -eq 0 ]]; then
    printf "%s | [WARN]  there is no *.jar files in the \"%s\" directory, exiting...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jars_home"
  elif [[ "$number_of_files" -gt 1 ]]; then
    printf "%s | [ERROR] ambiguous configuration, there are more then one JAR file to execute:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s\n" "${files[@]}"
    exit 1
  fi

  local result
  result="$2"
  if [ ${#files[@]} -eq 0 ]; then
    # no files in the dir
    eval "$result"=""
  else
    # directory not empty
    eval "$result"="${files[0]}"
  fi
}

# ------------------------------------------------------------------------------
# Inserts the missing KV pairs into the Hashicorp Consul.
#
# Parameters:
#    param 1: path to the *.properties file
#    param 2: the key context in the KV store
# ------------------------------------------------------------------------------
insert_kv() {
  local _properties_file _key_context
  _properties_file="$1"
  _key_context="$2"

  while IFS='=' read -d $'\n' -r _key _value; do
    [[ "$_key" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
      _key="${_key_context}/${_key}"
      if ! consul_key_exists "$_key"; then
        consul_put_key "$_key" "$_value"
      fi
  done < "$_properties_file"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
printf "%s | [INFO]  inserting key/values into Hashicorp Consul...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

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
