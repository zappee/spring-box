#!/bin/bash -ue
# ******************************************************************************
# Shared, common bash functions.
#
# Since:  April 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi All rights reserved
# ******************************************************************************

# ------------------------------------------------------------------------------
# Copy file(s) from a remote machine to localhost.
#
# Parameters:
#    param 1: remote host
#    param 2: user on the remote host
#    param 3: password for the connecting user
#    param 4: path to the file on the remote machine
#    param 5: directory on the local machine where the file will be copied
# ------------------------------------------------------------------------------
function copy_from_remote_machine() {
  local remote_host remote_user remote_password remote_path local_path
  remote_host="$1"
  remote_user="$2"
  remote_password="$3"
  remote_path="$4"
  local_path="$5"

  printf "%s | [DEBUG] scp %s@%s:%s %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$remote_user" "$remote_host" "$remote_path" "$local_path"
  sshpass -p "$remote_password" scp \
    -o StrictHostKeyChecking=no \
    -o ConnectTimeout=2 \
    -o ConnectionAttempts=5 \
    "$remote_user@$remote_host:$remote_path" "$local_path"
}

# ------------------------------------------------------------------------------
# Decrypt the encrypted private key.
#
# Parameters:
#    param 1: the hostname of the machine that determine which private key will
#             be decrypted
# ------------------------------------------------------------------------------
function decrypt_private_key() {
  local host_name keystore_pass
  host_name="$1"
  keystore_pass="changeit"

  printf "%s | [INFO]  decrypting the encrypted private key...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        SSH_USER: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$SSH_USER"
  printf "%s | [DEBUG]    SSH_PASSWORD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$SSH_PASSWORD"
  printf "%s | [DEBUG]        PKI_HOST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PKI_HOST"
  printf "%s | [DEBUG]       host_name: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$host_name"
  printf "%s | [DEBUG]   keystore_pass: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_pass"
  sshpass -p "$SSH_PASSWORD" \
    ssh \
      -oStrictHostKeyChecking=no \
      "$SSH_USER@$PKI_HOST" "bash -lc 'openssl pkey -in /opt/easy-rsa/pki/private/$host_name.key -out /opt/easy-rsa/pki/private/$host_name.pem --passin pass:$keystore_pass'"
}

# ------------------------------------------------------------------------------
# FQDN to an LDAP DN string.
#
# com ->                       dc=com
# world.com ->                 dc=world,dc=com
# hello.world.com ->           dc=hello,dc=world,dc=com
# hello.beautiful.world.com -> dc=hello,dc=beautiful,dc=world,dc=com
#
# LDAP attributes
#    - CN = Common Name
#    - OU = Organizational Unit
#    - DC = Domain Component
#    - DN = Distinguished Name
#
# ${1//./ /} replaces all occurrence of '.' in '$1' with ' ' (a space). See
# the "Parameter Expansion" section of the Bash man page for details.
#
# The sed expression s/[^ ]*/dc=&/g searches for all groups of non-space
# characters and adds dc= in front of them (the & in the replacement means
# "whatever we matched in the first part of the expression").
#
# The sed expression s/ /,/g replaces all spaces with ,
# ------------------------------------------------------------------------------
function fqdn_to_ldap_dn() {
  sed -e 's/[^ ]*/dc=&/g' <<<"${1//./ }" -e 's/ /,/g'
 }

# ------------------------------------------------------------------------------
# This method generates a certificate for the server using the our Private
# Certificate Authority infrastructure.
#
# Parameters:
#    param 1: certificate type: server, client, serverClient
#    param 2: domain for which the certificate is generated
#    param 3: generate the certificate with SAN,
#             e.g. "DNS:pki.hello.com,DNS:pki.dc1.hello.com"
# ------------------------------------------------------------------------------
function generate_certificate() {
  local cert_type domain san
  cert_type="$1"
  domain="$2"
  san="${3:-}"

  printf "%s | [INFO]  generating a server certificate...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        PKI_HOST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$PKI_HOST"
  printf "%s | [DEBUG]        SSH_USER: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$SSH_USER"
  printf "%s | [DEBUG]    SSH_PASSWORD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$SSH_PASSWORD"
  printf "%s | [DEBUG]       cert_type: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$cert_type"
  printf "%s | [DEBUG]          domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]             san: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$san"
  sshpass -p "$SSH_PASSWORD" \
    ssh \
      -oStrictHostKeyChecking=no \
      "$SSH_USER@$PKI_HOST" "bash -lc '/opt/easy-rsa/generate-cert.sh $cert_type $domain $san'"
}

# ------------------------------------------------------------------------------
# Get the latest file that fits to the given pattern.
#
# Parameters:
#    param 1: directory to check
#    param 2: filename pattern
# ------------------------------------------------------------------------------
get_latest_file() {
  local directory pattern
  directory="$1"
  pattern="$2"
  printf "%s" "$(find "$directory" -name "$pattern" -type f -exec ls -t {} + | head -1)"
}

# ------------------------------------------------------------------------------
# Read value from a property file.
#
# Parameters:
#    param 1: property file
#    param 2: key
#    return:  the value of the key
# ------------------------------------------------------------------------------
get_value() {
  printf "%s" "$(grep -w "^$2" "$1" | cut -d'=' -f2)"
}

# ------------------------------------------------------------------------------
# Import a certificate into an existing keystore.
#
# Parameters:
#    param 1: alias name in the keystore
#    param 2: certificate to be imported
#    param 3: the keystore
#    param 4: the keystore password
# ------------------------------------------------------------------------------
function import_to_keystore() {
  local alias certificate keystore storepass
  alias="$1"
  certificate="$2"
  keystore="$3"
  storepass="$4"

  printf "%s | [INFO ] importing \"%s\" certificate into \"%s\" keystore, alias: \"%s\", keystore-password: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$certificate" "$keystore" "$alias" "$storepass"
  keytool \
    -importcert \
    -alias "$alias" \
    -file "$certificate" \
    -keystore "$keystore" \
    -storepass "$storepass" \
    -noprompt
}

# ------------------------------------------------------------------------------
# Log the execution of a bash script.
#
# Parameters:
#    param 1: path to the bash script
# ------------------------------------------------------------------------------
log_start() {
  local script_file="$1"
  printf "%s | [DEBUG] ====> executing the \"%s\" script...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
}

# ------------------------------------------------------------------------------
# Log the execution of a bash script.
#
# Parameters:
#    param 1: path to the bash script
# ------------------------------------------------------------------------------
log_end() {
  local script_file="$1"
  printf "%s | [DEBUG] <---- end of the \"%s\" script\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
}

# ------------------------------------------------------------------------------
# Set the container state to "ready" by opening a port.
# This indicates that the container and all services in the container is up and
# ready to server incoming requests. Containers running in the same docker
# network can use this port to decide whether a container is up.
#
# This runs at the background in order to does not block the execution.
# ------------------------------------------------------------------------------
function set_container_up_state() {
  printf "%s | [INFO]  docker container is READY to serve incoming requests\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] opening port %s...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$UP_SIGNAL_PORT"

  local marker_file
  marker_file="/tmp/first-startup.marker"
  touch "$marker_file"
  socat - tcp-listen:"$UP_SIGNAL_PORT",fork,reuseaddr &
  show_ready_message
}

# ------------------------------------------------------------------------------
# Shows an ANSI test that indicates that the container has been started.
# ------------------------------------------------------------------------------
function show_ready_message() {
  local fqdn
  fqdn=$(hostname -f)

  printf "%s | [INFO]  container %s has been started\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]  _                  _                            _             _           _ \n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] | |                | |                          | |           | |         | |\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] | |__   __ _ ___   | |__   ___  ___ _ __     ___| |_ __ _ _ __| |_ ___  __| |\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] | '_ \ / _\` / __|  | '_ \ / _ \/ _ \ '_ \   / __| __/ _\` | \'__| __/ _ \/ _\` |\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] | | | | (_| \__ \  | |_) |  __/  __/ | | |  \__ \ || (_| | |  | ||  __/ (_| |\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] |_| |_|\__,_|___/  |_.__/ \___|\___|_| |_|  |___/\__\__,_|_|   \__\___|\__,_|\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] Copyright (c) 2020-2026 Remal Software and Arnold Somogyi All rights reserved\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}

# ------------------------------------------------------------------------------
# This method is called when a SIGTERM signal appears.
# ------------------------------------------------------------------------------
function shutdown_trap() {
  printf "%s | [INFO]  shutting down the container...\n" "$(date +"%Y-%m-%d %H:%M:%S")"

  local script_file
  script_file="/shutdown-actions.sh"

  if [ -f "$script_file" ]; then
    local start elapsed
    start=$(date +%s)

    log_start "$script_file"
    . /shutdown-actions.sh
    elapsed=$(($(date +%s) - start))
    printf "%s | [INFO]  shutdown took %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$(date -d@$elapsed -u +%H\ hour\ %M\ day\ %S\ sec)"
    log_end "$script_file"
  else
    printf "%s | [WARN]  script \"%s\" not exist, ignoring it\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_file"
  fi
}

# ------------------------------------------------------------------------------
# Checks whether this is the first startup of the container or not.
# ------------------------------------------------------------------------------
function is_first_startup() {
  local marker_file
  marker_file="/tmp/first-startup.marker"

  if [ -f "$marker_file" ]; then
    printf "false"
  else
    printf "true"
  fi
}

# ------------------------------------------------------------------------------
# Wait for the given container to be up and ready to serve requests.
#
# Parameters:
#    param 1: the container's hostname or IP address
# ------------------------------------------------------------------------------
wait_for_container() {
  local domain
  domain="$1"
  printf "%s | [INFO]  waiting for the \"%s\" container, port: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain" "$UP_SIGNAL_PORT"
  while ! nc -w 5 -z "$domain" "$UP_SIGNAL_PORT" 2>/dev/null; do
    sleep 0.5
  done
  printf "%s | [INFO]  the \"%s\" container is up and running\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
}

# ------------------------------------------------------------------------------
# Wait until a given content appears in a file. Once the content appears the
# function exits and cleans up itself (kills the tail).
#
# WARNING: This method only scans  new contents in the file and the previous
#          lines are completely ignored!
#
# Parameters:
#    param 1: the file to be monitored
#    param 1: the expected content
# ------------------------------------------------------------------------------
wait_until_content_found() {
  local file_to_monitor required_string pid
  file_to_monitor="$1"
  required_string="$2"
  pid="$$"

  printf "%s | [DEBUG] monitoring the \"%s\" file and waiting until \"%s\" text appears...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$file_to_monitor" "$required_string"
  printf "%s | [DEBUG] own PID: \"%s\"...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$pid"
  grep -q "$required_string" <(tail -n +1 --pid "$pid" -F "$file_to_monitor")
  printf "%s | [DEBUG] expected content \"%s\" appeared, let's continue\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$required_string"
}
