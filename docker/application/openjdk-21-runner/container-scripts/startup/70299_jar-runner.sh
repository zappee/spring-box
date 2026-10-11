#!/bin/bash -ue
# ******************************************************************************
# Java JAR file runner.
#
# WARNING: Do not change the name of this file.
# The prefix in the filename ensures, that the JAR-Runner will run at the end of
# the startup flow. This helps for the container to run all the script files
# from the 'startup' directory first. For example, it ensure that the Postgres
# database server will be started before the Java application.
#
# Since:  February 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ------------------------------------------------------------------------------
# Jar validation error message.
# ------------------------------------------------------------------------------
show_no_jar_to_execute_error() {
  printf "%s | [WARN]  there is no JAR file to execute\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# Jar validation error message.
# ------------------------------------------------------------------------------
show_ambiguous_jars_error() {
  printf "%s | [ERROR] ambiguous configuration, there are more then one JAR file to execute\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  exit 1
}

# ------------------------------------------------------------------------------
# Executable Jar runner.
# ------------------------------------------------------------------------------
jar_runner() {
  local jar_files jar_file jvm_app_name
  jar_files=("$JAR_HOME"/*.jar)
  jar_file="${jar_files[0]}"
  jvm_app_name="${jar_file##*/}"

  local jvm_params
  if [[ "${JAVA_DEBUG^^}" == "TRUE" && -n "$JAVA_DEBUG_PORT" ]]; then
    jvm_params="-Dapp.name=$jvm_app_name $JAVA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:$JAVA_DEBUG_PORT"
  else
    jvm_params="-Dapp.name=$jvm_app_name $JAVA_OPTS"
  fi

  local health_check_cmd
  health_check_cmd="curl -X GET -s $HEALTH_CHECK_URI 2>&1 | grep -m 1 '$EXPECTED_HEALTH_CHECK_STATE'"

  printf "%s | [INFO]  running the %s JAR file...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  printf "%s | [DEBUG]             java debug enabled: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAVA_DEBUG"
  printf "%s | [DEBUG]                java debug port: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAVA_DEBUG_PORT"
  printf "%s | [DEBUG]                    JVM options: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jvm_params"
  printf "%s | [DEBUG]                       JAR home: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAR_HOME"
  printf "%s | [DEBUG]                       JAR file: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  printf "%s | [DEBUG]         JVM app.name parameter: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jvm_app_name"
  printf "%s | [DEBUG]               health-check URI: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$HEALTH_CHECK_URI"
  printf "%s | [DEBUG]    expected health-check state: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EXPECTED_HEALTH_CHECK_STATE"
  printf "%s | [DEBUG]           health-check command: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${health_check_cmd[*]}"
  printf "%s | [DEBUG]             consul server host: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CONSUL_SERVER_HOSTNAME"
  printf "%s | [DEBUG] java version:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  java -version

  cd "$JAR_HOME" || { echo "Error while trying to change directory from $(pwd) to $JAR_HOME"; exit 1; }
  printf "%s | [INFO]  starting the %s java application...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$jar_file"
  java $jvm_params -jar "$jar_file" 2>&1 &

  if [[ "${HEALTH_CHECK^^}" == "TRUE" && -n "$HEALTH_CHECK_URI" && -n "$EXPECTED_HEALTH_CHECK_STATE" ]]; then
    printf "%s | [INFO]  waiting for health checks to pass the test...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

    # if any pipeline ever ends with a non-zero ('error') exit status,
    # terminate the script immediately
    set +e
    until eval "$health_check_cmd"; do sleep 0.5 ; done
    set -e
    printf "%s | [INFO]  the Java application is up and running\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"

FQDN=$(hostname -f)
export FQDN

number_of_jars=$(find "$JAR_HOME" -maxdepth 1 -type f -name "*.jar" | wc -l)
printf "%s | [DEBUG] JAR files in the %s directory: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAR_HOME" "$number_of_jars"

if [[ "$number_of_jars" -eq 0 ]]; then
  show_no_jar_to_execute_error
elif [[ "$number_of_jars" -gt 1 ]]; then
  show_ambiguous_jars_error
else
  jar_runner
fi

log_end "$0"
