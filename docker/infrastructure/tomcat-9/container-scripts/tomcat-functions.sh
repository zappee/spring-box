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
# Get a value from a properties file.
#
# Parameters:
#    param 1: properties file
#    param 2: key
# ------------------------------------------------------------------------------
function get_value {
  local properties_file key value
  properties_file="$1"
  key="$2"
  value=$(< "$properties_file" grep "^\\s*${key}=" | cut -d "=" -f 2-)
  printf "%s" "$value"
}

# ------------------------------------------------------------------------------
# Start the Apache Tomcat Server and wait for the full server start-up and for
# the deployment of the applications. 
# ------------------------------------------------------------------------------
function start_tomcat() {
  local env_file java_opts_key java_opts_value
  env_file="$CATALINA_HOME/bin/setenv.sh"
  java_opts_key="JAVA_OPTS"

  if [ -e "$env_file" ]; then
      java_opts_value="$(get_value "$env_file" "JAVA_OPTS")"
  else
      java_opts_value="<File does not exist: $env_file>"
  fi

  printf "%s | [INFO ] starting Apache Tomcat...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    env file:      \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$env_file"
  printf "%s | [DEBUG]    %s:     %s\n"  "$(date +"%Y-%m-%d %H:%M:%S")" "$java_opts_key" "$java_opts_value"
  printf "%s | [DEBUG]    CATALINA_OPTS: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${CATALINA_OPTS:-}"

  "$CATALINA_HOME/bin/catalina.sh" start
  tail -n +1 -F "$CATALINA_HOME/logs/catalina.out" &
  wait_until_content_found "$CATALINA_HOME/logs/catalina.out" "Server startup in"
  printf "%s | [INFO ] Apache Tomcat has been started...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Stop the Apache Tomcat Server and wait until the server stops completely.
# ------------------------------------------------------------------------------
function stop_tomcat() {
  printf "%s | [INFO ] stopping Apache Tomcat...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  "$CATALINA_HOME/bin/catalina.sh" stop 15
  wait_until_content_found "$CATALINA_HOME/logs/catalina.out" "Destroying ProtocolHandler"
  printf "%s | [INFO ] Apache Tomcat has been stopped\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
