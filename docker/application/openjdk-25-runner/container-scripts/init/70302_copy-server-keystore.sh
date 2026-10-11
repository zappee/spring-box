#!/bin/bash -ue
# ******************************************************************************
# Copy the server keystore from Private-PKI server. The keystore will be used
# by Tomcat for TLS/HTTPS.
#
# Since:  March 2026
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
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
