#!/bin/bash -ue
# ******************************************************************************
# Apache Tomcat Server management utilities.
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
# Get a value from a properties file by its key.
#
# Arguments:
#    $1: Path to the properties file
#    $2: The configuration key to look up
#
# Returns:
#    0: Success, outputs the retrieved value
#    1: Error, file is unreadable, parameters are missing, or key is not found
# ------------------------------------------------------------------------------
function get_value {
  local properties_file="$1"
  local key="$2"

  # Validate that the file exists and is readable.
  if [[ ! -r "$properties_file" ]]; then
    printf "%s | [ERROR ] Properties file '%s' does not exist." "$(date +"%Y-%m-%d %H:%M:%S")" "$properties_file"
    return 1
  fi

  # Validate that the key is not empty.
  if [[ -z "$key" ]]; then
    printf "%s | [ERROR ] Missing lookup key parameter." "$(date +"%Y-%m-%d %H:%M:%S")"
    return 1
  fi

  local value
  value=$(grep "^[[:space:]]*${key}=" "$properties_file" | cut -d "=" -f 2-)

  printf "%s" "$value"
}

# ------------------------------------------------------------------------------
# Start the Apache Tomcat Server, stream logs, and wait for full startup.
# ------------------------------------------------------------------------------
function start_tomcat() {
  local env_file java_opts_key java_opts_value
  env_file="$CATALINA_HOME/bin/setenv.sh"
  java_opts_key="JAVA_OPTS"

  printf "%s | [INFO ] Starting Apache Tomcat...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]       CATALINA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${CATALINA_HOME:-}"
  printf "%s | [DEBUG]       CATALINA_OPTS: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${CATALINA_OPTS:-}"
  printf "%s | [DEBUG]    Environment file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$env_file"

  if [[ -f "$env_file" ]]; then
      java_opts_value="$(get_value "$env_file" "$java_opts_key")"
  else
      java_opts_value="<File not found: ${env_file}>"
  fi
  printf "%s | [DEBUG]           %s: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$java_opts_key" "$java_opts_value"

  "$CATALINA_HOME/bin/catalina.sh" start
  tail -n +1 -F "$CATALINA_HOME/logs/catalina.out" &
  wait_until_content_found "$CATALINA_HOME/logs/catalina.out" "Server startup in"
  printf "%s | [INFO ] Apache Tomcat started successfully and is ready to accept connections.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Stop the Apache Tomcat Server and wait until the server stops completely.
# ------------------------------------------------------------------------------
function stop_tomcat() {
  printf "%s | [INFO ] Stopping Apache Tomcat...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    CATALINA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${CATALINA_HOME:-}"

  "$CATALINA_HOME/bin/catalina.sh" stop 15 -force
  wait_until_content_found "$CATALINA_HOME/logs/catalina.out" "Destroying ProtocolHandler"
  printf "%s | [INFO ] Apache Tomcat has been completely stopped.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
