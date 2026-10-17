#!/bin/bash -ue
# ******************************************************************************
# File utility for the Remal Spring Box.
#
# Because installer binaries are too large for source control, the Git repository
# stores only zero-byte placeholder files to mark their locations. This script
# synchronizes and updates those files based on the specified operational mode.
#
# Prerequisites:
#   The REMAL_BINARY_HOME and PROJECT_HOME environment variables must be set
#   correctly prior to execution.
#
# Usage:
#   ./update-binaries.sh [mode]
#
# Arguments:
#   0        Placeholder mode: Overwrites large binary files with zero-byte markers.
#   1        Restore mode: Copies the binaries from the source to Docker image build
#            directories.
#   Default: 0
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
REMAL_BINARY_HOME="$HOME/Applications/tomcat/apache-tomcat-10.1.33/webapps/docker-build"
PROJECT_HOME="$HOME/Java/springbox"

BINARIES=(
  "DS-7.3.0.zip;docker/infrastructure/forgerock-ds/bin"
  "AM-7.3.0.war;docker/infrastructure/forgerock-am/bin"
  "AM-SSOConfiguratorTools-5.1.3.18.zip;docker/infrastructure/forgerock-am/bin"
  "apache-tomcat-9.0.71.tar.gz;docker/infrastructure/tomcat-9/bin"
  "EasyRSA-3.2.5.tgz;docker/infrastructure/easy-rsa-pki/bin"
  "consul_1.22.5_linux_386.zip;docker/infrastructure/hcp-consul-for-java-21/bin"
  "consul_1.22.5_linux_386.zip;docker/infrastructure/hcp-consul-for-java-25/bin"
  "vault_1.21.4_linux_386.zip;docker/infrastructure/hcp-vault/bin"
  "prometheus-3.10.0.linux-amd64.tar.gz;docker/monitoring/prometheus/bin"
  "grafana-enterprise_12.4.0_22325204712_linux_amd64.tar.gz;docker/monitoring/grafana/bin"
  "hazelcast-5.6.0-slim.tar.gz;docker/infrastructure/hazelcast-platform/bin"
)

# ----------------------------------------------------------------------------
# Show the manual.
# ------------------------------------------------------------------------------
function show_manual() {
  printf "%s" "$COLOR_INFO"
  printf "The install binary files are big so we keep these files out of the source code\n"
  printf "repository. In the Git repo we only keep zero length marker files as\n"
  printf "placeholders to indicate the original file. This script updates that files.\n\n"
  printf "%s" "$COLOR_DEFAULT"
}

# ----------------------------------------------------------------------------
# Show the usage.
# ------------------------------------------------------------------------------
function show_usage() {
  printf "%s" "$COLOR_USAGE"
  printf "Usage: ./update-binaries.sh [0|1]\n"
  printf "   0: overwrites the binary files with zero length marker files\n"
  printf "   1: copy the binaries from the source to the target directories\n"
  printf "   default: 0\n\n"
  printf "%s" "$COLOR_DEFAULT"
  printf "REMAL_BINARY_HOME: %s\n" "$REMAL_BINARY_HOME"
  printf "PROJECT_HOME     : %s\n\n" "$PROJECT_HOME"
}

# ----------------------------------------------------------------------------
# Show the user's selection.
# ------------------------------------------------------------------------------
function show_user_selection() {
  printf "%s" "$COLOR_USAGE"
  printf "Selected: %s\n" "$1"
  printf "%s" "$COLOR_DEFAULT"
}

# ----------------------------------------------------------------------------
# Validate the user input.
# ------------------------------------------------------------------------------
function validate_user_input() {
  if ! [[ "$1" =~ ^("0"|"1")$ ]]; then
      printf "%sIllegal number of parameters.%s\n\n" "$COLOR_ERROR" "$COLOR_DEFAULT"
      show_usage
      exit 1
  fi
}

# ----------------------------------------------------------------------------
# Waiting for user's approval to continue.
# ------------------------------------------------------------------------------
function waiting_for_approval() {
  read -n1 -r -p $'Are you sure you want to continue? [y/n] ' key
  printf "\n"
  if [[ ! $key =~ ^[Yy]$ ]]; then
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
COLOR_DEFAULT=$(tput sgr0)
COLOR_ERROR=$(tput setaf 196)
COLOR_INFO=$(tput setaf 154)
COLOR_USAGE=$(tput setaf 226)

show_manual
show_usage
COMMAND=${1:-"0"}
validate_user_input "$COMMAND"
show_user_selection "$COMMAND"
waiting_for_approval

index=0
for binary in "${BINARIES[@]}"; do
  IFS=';' read -r file_name target_dir <<< "$binary"
  index=$((index += 1))
  if [[ "$COMMAND" == "0" ]]; then
    printf "%s) overwriting %s file in %s directory with a marker file...\n" "$index" "$file_name" "$PROJECT_HOME/$target_dir"
    rm "$PROJECT_HOME/$target_dir/$file_name"
    touch "$PROJECT_HOME/$target_dir/$file_name"
  else
    printf "%s) copying %s to %s directory...\n" "$index" "$file_name" "$target_dir"
    cp "$REMAL_BINARY_HOME/$file_name" "$PROJECT_HOME/$target_dir/"
  fi
done
