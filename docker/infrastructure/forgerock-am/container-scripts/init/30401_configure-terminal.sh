#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
log_start "$0"
{
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "AM_HOME" "$AM_HOME"
  printf "export %s=\"%s\"\n" "AM_CONFIG_TOOL_HOME" "$AM_CONFIG_TOOL_HOME"
  printf "export %s=\"%s\"\n" "AM_CONFIG_TOOL" "$AM_CONFIG_TOOL"
  printf "cd %s\n" "$AM_HOME"
} >> /etc/profile
log_end "$0"
