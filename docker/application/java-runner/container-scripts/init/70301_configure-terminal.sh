#!/bin/bash -ue
# ******************************************************************************
# Bash environment setup for a Docker container.
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
# Main program execution.
# ------------------------------------------------------------------------------
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
  printf "export %s=\"%s\"\n" "CONSUL_SERVER_HOSTNAME" "$CONSUL_SERVER_HOSTNAME"
  printf "cd %s\n" "$JAR_HOME"
} >> /etc/profile
log_end "$0"
