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
log_start "$0"
{
  printf "export %s=\"%s\"\n" "PKI_HOST" "$PKI_HOST"
  printf "export %s=\"%s\"\n" "AM_HOME" "$AM_HOME"
  printf "export %s=\"%s\"\n" "AM_CONFIG_TOOL_HOME" "$AM_CONFIG_TOOL_HOME"
  printf "export %s=\"%s\"\n" "AM_CONFIG_TOOL" "$AM_CONFIG_TOOL"
  printf "cd %s\n" "$AM_HOME"
} >> /etc/profile
log_end "$0"
