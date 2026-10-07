#!/bin/bash -ue
# *******************************************************************************
# Shared common functions for shell scripts.
#
# Since:  April 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************

# -------------------------------------------------------------------------------
# Copy file(s) from a remote machine to localhost.
#
# Arguments:
#    $1: Remote host address
#    $2: Username on the remote host
#    $3: Password for the remote user
#    $4: Source path of the file on the remote machine
#    $5: Destination directory on the local machine
# -------------------------------------------------------------------------------
function copy_from_remote_machine() {
  local remote_host="$1"
  local remote_user="$2"
  local remote_password="$3"
  local remote_path="$4"
  local local_path="$5"

  printf "%s | [DEBUG] scp %s@%s:%s %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$remote_user" "$remote_host" "$remote_path" "$local_path"
  sshpass -p "$remote_password" scp \
    -o StrictHostKeyChecking=no \
    -o ConnectTimeout=2 \
    -o ConnectionAttempts=5 \
    "$remote_user@$remote_host:$remote_path" "$local_path"
}

# -------------------------------------------------------------------------------
# Decrypt the encrypted private key.
#
# Arguments:
#    $1: Hostname used to determine which private key to decrypt
# -------------------------------------------------------------------------------
function decrypt_private_key() {
  local host_name="$1"
  local keystore_pass="changeit"

  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  local remote_cmd
  remote_cmd=$(printf "bash -lc 'openssl pkey -in /opt/easy-rsa/pki/private/%q.key -out /opt/easy-rsa/pki/private/%q.pem -passin pass:%q'" "$host_name" "$host_name" "$keystore_pass")

  printf "%s | [INFO]  Decrypting the private key...\n" "$timestamp"
  printf "%s | [DEBUG]        PKI_HOST: \"%s\"\n" "$timestamp" "$PKI_HOST"
  printf "%s | [DEBUG]        SSH_USER: \"%s\"\n" "$timestamp" "$SSH_USER"
  printf "%s | [DEBUG]    SSH_PASSWORD: \"%s\"\n" "$timestamp" "$SSH_PASSWORD"
  printf "%s | [DEBUG]       Host Name: \"%s\"\n" "$timestamp" "$host_name"
  printf "%s | [DEBUG]   Keystore Pass: \"%s\"\n" "$timestamp" "$keystore_pass"
  printf "%s | [DEBUG]         Command: \"%s\"\n" "$timestamp" "$remote_cmd"

  sshpass -p "$SSH_PASSWORD" ssh -oStrictHostKeyChecking=no "$SSH_USER@$PKI_HOST" "$remote_cmd"
}

# -------------------------------------------------------------------------------
# Convert a Fully Qualified Domain Name (FQDN) to an LDAP DN string.
#
# Examples:
#   com                         ->  dc=com
#   world.com                   ->  dc=world,dc=com
#   hello.world.com             ->  dc=hello,dc=world,dc=com
#   hello.beautiful.world.com   ->  dc=hello,dc=beautiful,dc=world,dc=com
#
# LDAP attribute reference:
#   - CN = Common Name
#   - OU = Organizational Unit
#   - DC = Domain Component
#   - DN = Distinguished Name
#
# Technical Details:
#   - ${1//./ /} replaces all periods in '$1' with spaces. See the
#     "Parameter Expansion" section of the Bash man page for more details.
#
#   - sed 's/[^ ]*/dc=&/g' prepends 'dc=' to all groups of non-space
#     characters (where '&' references the matched text).
#
#   - sed 's/ /,/g' converts all remaining spaces into commas.
# -------------------------------------------------------------------------------
function fqdn_to_ldap_dn() {
  sed -e 's/[^ ]*/dc=&/g' <<<"${1//./ }" -e 's/ /,/g'
}

# -------------------------------------------------------------------------------
# Generate a certificate using our Private Certificate Authority (PCA)
# infrastructure.
#
# Arguments:
#    $1: Certificate type (options: server, client, serverClient)
#    $2: Target domain for the certificate
#    $3: Subject Alternative Names (SAN), formatted as a string
#        e.g., "DNS:pki.hello.com,DNS:pki.dc1.hello.com"
# -------------------------------------------------------------------------------
function generate_certificate() {
  local cert_type="$1"
  local domain="$2"
  local san="${3:-}"

  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  local remote_cmd
  remote_cmd=$(printf "bash -lc '/opt/easy-rsa/generate-cert.sh %q %q %q'" "$cert_type" "$domain" "$san")

  printf "%s | [INFO]  Generating a server certificate...\n" "$timestamp"
  printf "%s | [DEBUG]        PKI_HOST: \"%s\"\n" "$timestamp" "$PKI_HOST"
  printf "%s | [DEBUG]        SSH_USER: \"%s\"\n" "$timestamp" "$SSH_USER"
  printf "%s | [DEBUG]    SSH_PASSWORD: \"%s\"\n" "$timestamp" "$SSH_PASSWORD"
  printf "%s | [DEBUG]       Cert Type: \"%s\"\n" "$timestamp" "$cert_type"
  printf "%s | [DEBUG]          Domain: \"%s\"\n" "$timestamp" "$domain"
  printf "%s | [DEBUG]             SAN: \"%s\"\n" "$timestamp" "$san"
  printf "%s | [DEBUG]         Command: \"%s\"\n" "$timestamp" "$remote_cmd"

  sshpass -p "$SSH_PASSWORD" ssh -oStrictHostKeyChecking=no "$SSH_USER@$PKI_HOST" "$remote_cmd"
}

# -------------------------------------------------------------------------------
# Find the latest file that matches the specified pattern.
#
# Arguments:
#    $1: Directory to search
#    $2: Filename pattern (e.g. "*.log")
# -------------------------------------------------------------------------------
get_latest_file() {
  local directory="$1"
  local pattern="$2"
  printf "%s" "$(find "$directory" -name "$pattern" -type f -exec ls -t {} + | head -1)"
}

# -------------------------------------------------------------------------------
# Read a value from a property file.
#
# Arguments:
#    $1: Path to the property file
#    $2: The key to look up
#
# Outputs:
#    Prints the value associated with the key to stdout
# -------------------------------------------------------------------------------
get_value() {
  printf "%s" "$(grep -w "^$2" "$1" | cut -d'=' -f2)"
}

# -------------------------------------------------------------------------------
# Import a certificate into an existing keystore.
#
# Arguments:
#    $1: Alias name for the certificate within the keystore
#    $2: Path to the certificate file to be imported
#    $3: Path to the target keystore file
#    $4: Password for the keystore
# -------------------------------------------------------------------------------
function import_to_keystore() {
  local alias certificate keystore storepass
  alias="$1"
  certificate="$2"
  keystore="$3"
  storepass="$4"

  printf "%s | [INFO ] Importing certificate \"%s\" into keystore \"%s\" (alias: \"%s\"), keystore-password: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$certificate" "$keystore" "$alias" "$storepass"
  keytool \
    -importcert \
    -alias "$alias" \
    -file "$certificate" \
    -keystore "$keystore" \
    -storepass "$storepass" \
    -noprompt
}

# -------------------------------------------------------------------------------
# Log the execution details of a Bash script.
#
# Arguments:
#    $1: Path to the Bash script being executed
# -------------------------------------------------------------------------------
log_start() {
  local script_file="$1"
  printf "%s | [DEBUG] ====> Executing script \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
}

# -------------------------------------------------------------------------------
# Log the execution details of a Bash script.
#
# Arguments:
#    $1: Path to the Bash script being executed
# -------------------------------------------------------------------------------
log_end() {
  local script_file="$1"
  printf "%s | [DEBUG] <---- Finished script: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
}

# -------------------------------------------------------------------------------
# Open the 'Readiness signal port' by opening a network port.
#
# This signal indicates that the container and all of its internal services are
# up and ready to serve incoming requests. Other containers on the same Docker
# network can probe this port to perform health/readiness checks.
#
# This process runs in the background so it does not block execution.
# -------------------------------------------------------------------------------
function set_container_up_state() {
  printf "%s | [INFO]  Docker container is READY to serve incoming requests.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] Opening readiness signal port %s...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$UP_SIGNAL_PORT"

  local marker_file="/tmp/first-startup.marker"
  touch "$marker_file"

  socat - tcp-listen:"$UP_SIGNAL_PORT",fork,reuseaddr &
  show_ready_message
}

# -------------------------------------------------------------------------------
# Display an ANSI-formatted text banner indicating the container has started.
# -------------------------------------------------------------------------------
function show_ready_message() {
  local fqdn
  fqdn=$(hostname -f)

  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  printf "%s | [INFO]  Container %s has been started.\n" "$timestamp" "$fqdn"
  printf "%s | [DEBUG]  _                   _                             _             _           _ \n" "$timestamp"
  printf "%s | [DEBUG] | |                 | |                           | |           | |         | |\n" "$timestamp"
  printf "%s | [DEBUG] | |__   __ _ ___    | |__   ___  ___ _ __      ___| |_ __ _ _ __| |_ ___  __| |\n" "$timestamp"
  printf "%s | [DEBUG] | '_ \\ / _\` / __|   | '_ \\ / _ \\/ _ \\ '_ \\    / __| __/ _\` | \\'__| __/ _ \\/ _\` |\n" "$timestamp"
  printf "%s | [DEBUG] | | | | (_| \__ \   | |_) |  __/  __/ | | |   \__ \ || (_| | |  | ||  __/ (_| |\n" "$timestamp"
  printf "%s | [DEBUG] |_| |_|\__,_|___/   |_.__/ \___|\___|_| |_|   |___/\__\__,_|_|   \__\___|\__,_|\n" "$timestamp"
  printf "%s | [DEBUG] Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.\n" "$timestamp"
}

# -------------------------------------------------------------------------------
# Handle the SIGTERM signal for graceful shutdown.
# -------------------------------------------------------------------------------
function shutdown_trap() {
  printf "%s | [INFO]  Shutting down the container...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

  local script_file
  script_file="/shutdown-actions.sh"

  if [ -f "$script_file" ]; then
    local start_time elapsed_seconds
    start_time=$(date +%s)

    log_start "$script_file"
    . shutdown-actions.sh

    elapsed_seconds=$(($(date +%s) - start_time))
    local hours=$((elapsed_seconds / 3600))
    local minutes=$(( (elapsed_seconds % 3600) / 60 ))
    local seconds=$((elapsed_seconds % 60))

    printf "%s | [INFO]  Shutdown completed in %02d hour(s) %02d min(s) %02d sec(s)\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$hours" "$minutes" "$seconds"
    log_end "$script_file"
  else
    printf "%s | [WARN]  Script \"%s\" does not exist, skipping execution.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
  fi
}

# -------------------------------------------------------------------------------
# Determine if this is the container's first run.
# -------------------------------------------------------------------------------
function is_first_startup() {
  local marker_file
  marker_file="/tmp/first-startup.marker"

  if [ -f "$marker_file" ]; then
    printf "false"
  else
    printf "true"
  fi
}

# -------------------------------------------------------------------------------
# Block execution until the target container is operational and ready for
# serving requests.
#
# Arguments:
#    $1: Hostname or IP address of the target container
# -------------------------------------------------------------------------------
wait_for_container() {
  local domain="$1"
  printf "%s | [INFO]  Waiting for container \"%s\" on port \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain" "$UP_SIGNAL_PORT"
  while ! nc -w 5 -z "$domain" "$UP_SIGNAL_PORT" 2>/dev/null; do
    sleep 0.5
  done
  printf "%s | [INFO]  Container \"%s\" is up and running.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
}

# -------------------------------------------------------------------------------
# Monitor a file for a specific pattern. Exits and stops the 'tail' process
# immediately upon detection.
#
# WARNING: This method only scans newly appended content; existing lines in
#          the file are completely ignored!
#
# Arguments:
#    $1: Path to the file being monitored
#    $2: The expected string or pattern to match
# -------------------------------------------------------------------------------
wait_until_content_found() {
  local file_to_monitor="$1"
  local required_string="$2"
  local pid="$$"

  printf "%s | [DEBUG] Monitoring file \"%s\" until text \"%s\" appears...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_monitor" "$required_string"
  printf "%s | [DEBUG] Self PID: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$pid"
  grep -q "$required_string" <(tail -n +1 --pid "$pid" -F "$file_to_monitor")
  printf "%s | [DEBUG] Expected content \"%s\" detected, Continuing.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$required_string"
}
