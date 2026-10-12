#!/bin/bash -ue
# ******************************************************************************
# Copy the server keystore from the Private-PKI machine for Tomcat TLS/HTTPS.
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
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"

FQDN=$(hostname -f)
KEYSTORE_HOME="/tmp"
KEYSTORE_FILE="$FQDN.p12"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$KEYSTORE_FILE" "$KEYSTORE_HOME"

log_end "$0"
