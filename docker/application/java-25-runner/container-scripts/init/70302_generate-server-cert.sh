#!/bin/bash -ue
# ******************************************************************************
# Generates server certificate using the Remal Spring Box PKI infrastructure.
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
FQDN=$(hostname -f)

generate_certificate "serverClient" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.key" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/issued/$FQDN.crt" "$KEYSTORE_HOME"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/ca.crt" "$KEYSTORE_HOME"
decrypt_private_key "$FQDN"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$FQDN.pem" "$KEYSTORE_HOME"

log_end "$0"
