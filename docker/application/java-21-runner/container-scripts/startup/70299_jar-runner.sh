#!/bin/bash -ue
# ******************************************************************************
# JAR file executor.
#
# WARNING: Do not rename this file.
# The alphanumeric prefix in the filename enforces execution order, ensuring
# this script runs at the very end of the container startup sequence. This
# guarantees that all prerequisite scripts in the 'startup' directory (such as
# starter scripts) complete before the Java application startup.
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
# Logs a warning indicating that no executable JAR file was found.
# ------------------------------------------------------------------------------
show_no_jar_to_execute_error() {
  printf "%s | [WARN ] No JAR file found to execute.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Logs an error indicating that multiple JAR files were found, creating
# ambiguity. Terminating execution with exit code 1.
# ------------------------------------------------------------------------------
show_ambiguous_jars_error() {
  printf "%s | [ERROR] Ambiguous configuration. More than one JAR file was found to execute.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  exit 1
}

# ------------------------------------------------------------------------------
# JAR file runner.
# ------------------------------------------------------------------------------
jar_runner() {
  local jar_files jar_file app_name
  jar_files=("$JAR_HOME"/*.jar)
  jar_file="${jar_files[0]}"
  app_name="${jar_file##*/}"

  local jvm_params
  if [[ "${JAVA_DEBUG^^}" == "TRUE" && -n "$JAVA_DEBUG_PORT" ]]; then
    jvm_params="-Dapp.name=$app_name $JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:$JAVA_DEBUG_PORT"
  else
    jvm_params="-Dapp.name=$app_name $JAVA_OPTS"
  fi

  local health_check_cmd
  health_check_cmd="curl -X GET -s $HEALTH_CHECK_URI 2>&1 | grep -m 1 '$EXPECTED_HEALTH_CHECK_STATE'"

  printf "%s | [INFO ] Preparing to execute '%s' JAR file...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  printf "%s | [DEBUG]                     JAVA_DEBUG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAVA_DEBUG"
  printf "%s | [DEBUG]                JAVA_DEBUG_PORT: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAVA_DEBUG_PORT"
  printf "%s | [DEBUG]                     JVM PARAMS: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jvm_params"
  printf "%s | [DEBUG]                       JAR_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAR_HOME"
  printf "%s | [DEBUG]                       JAR FILE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  printf "%s | [DEBUG]                       app.name: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$app_name"
  printf "%s | [DEBUG]               HEALTH_CHECK_URI: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HEALTH_CHECK_URI"
  printf "%s | [DEBUG]    EXPECTED_HEALTH_CHECK_STATE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EXPECTED_HEALTH_CHECK_STATE"
  printf "%s | [DEBUG]           health check command: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$health_check_cmd"
  printf "%s | [DEBUG]         CONSUL_SERVER_HOSTNAME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_SERVER_HOSTNAME"
  printf "%s | [DEBUG] Java version:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  java -version

  cd "$JAR_HOME" || { echo "Error while trying to change directory from $(pwd) to $JAR_HOME"; exit 1; }
  printf "%s | [INFO ] Executing the %s Java application...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  java $jvm_params -jar "$jar_file" 2>&1 &

  if [[ "${HEALTH_CHECK^^}" == "TRUE" && -n "$HEALTH_CHECK_URI" && -n "$EXPECTED_HEALTH_CHECK_STATE" ]]; then
    printf "%s | [INFO ] Waiting for health checks to pass...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

    # Temporarily disable 'exit on error' status flags to allow health checking polling.
    set +e
    until eval "$health_check_cmd"; do sleep 0.5 ; done
    set -e
    printf "%s | [INFO ] The Java application is up and running.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"

FQDN=$(hostname -f)
export FQDN

number_of_jars=$(find "$JAR_HOME" -maxdepth 1 -type f -name "*.jar" | wc -l)
printf "%s | [DEBUG] JAR files in the '%s' directory: %d\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAR_HOME" "$number_of_jars"

if [[ "$number_of_jars" -eq 0 ]]; then
  show_no_jar_to_execute_error
elif [[ "$number_of_jars" -gt 1 ]]; then
  show_ambiguous_jars_error
else
  jar_runner
fi

log_end "$0"
