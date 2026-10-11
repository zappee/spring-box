#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

log_start "$0"

{
  printf "export %s=\"%s\"\n" "JAR_HOME" "$JAR_HOME"
  printf "export %s=\"%s\"\n" "JAVA_OPTS" "$JAVA_OPTS"
  printf "export %s=\"%s\"\n" "JAVA_DEBUG" "$JAVA_DEBUG"
  printf "export %s=\"%s\"\n" "JAVA_DEBUG_PORT" "$JAVA_DEBUG_PORT"
  printf "export %s=\"%s\"\n" "HEALTH_CHECK" "$HEALTH_CHECK"
  printf "export %s=\"%s\"\n" "HEALTH_CHECK_URI" "$HEALTH_CHECK_URI"
  printf "export %s=\"%s\"\n" "EXPECTED_HEALTH_CHECK_STATE" "$EXPECTED_HEALTH_CHECK_STATE"
  printf "export %s=\"%s\"\n" "FQDN" "$(hostname -f)"
  printf "cd %s\n" "$JAR_HOME"
} >> /etc/profile

log_end "$0"
