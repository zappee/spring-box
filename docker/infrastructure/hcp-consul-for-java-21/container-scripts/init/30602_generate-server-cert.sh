#!/bin/bash -ue
# ******************************************************************************
# Generate a server cert using the Private PKI infrastructure.
#
# Since:  November 2023
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

generate_certificate "serverClient" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.key" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/issued/$FQDN.crt" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/ca.crt" "$KEYSTORE_HOME"

decrypt_private_key "$FQDN"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.pem" "$KEYSTORE_HOME"

log_end "$0"
