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
  printf "%s\n" "alias ll='ls -alF'"
  printf "%s\n" "alias ls='ls --color=auto'"
  printf "%s\n" "PS1='${IMAGE_NAME}:${IMAGE_TAG}:[\u@\H]\\$ '"
} >> ~/.bashrc

{
  printf "export %s=\"%s\"\n" "IMAGE_NAME" "$IMAGE_NAME"
  printf "export %s=\"%s\"\n" "IMAGE_TAG" "$IMAGE_TAG"
  printf "export %s=\"%s\"\n" "IMAGE_DESCRIPTION" "$IMAGE_DESCRIPTION"
  printf "export %s=\"%s\"\n" "IMAGE_AUTHOR" "$IMAGE_AUTHOR"
  printf "export %s=\"%s\"\n" "SSH_USER" "$SSH_USER"
  printf "export %s=\"%s\"\n" "SSH_PASSWORD" "$SSH_PASSWORD"
  printf "export %s=\"%s\"\n" "UP_SIGNAL_PORT" "$UP_SIGNAL_PORT"
} >> /etc/profile
log_end "$0"
