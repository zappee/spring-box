#!/bin/bash -ue
# ******************************************************************************
# Installs and configures Easy-RSA.
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
cd "$EASYRSA_HOME"

# installing easy-rsa
printf "%s | [INFO ] initializing easy-rsa...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
./easyrsa init-pki

VARS="$EASYRSA_HOME/pki/vars"
cp vars.example "$VARS"
{
  printf "set_var EASYRSA_REQ_CN \"%s\"\n" "$EASYRSA_REQ_CN"
  printf "set_var EASYRSA_REQ_COUNTRY \"%s\"\n" "$EASYRSA_REQ_COUNTRY"
  printf "set_var EASYRSA_REQ_PROVINCE \"%s\"\n" "$EASYRSA_REQ_PROVINCE"
  printf "set_var EASYRSA_REQ_CITY \"%s\"\n" "$EASYRSA_REQ_CITY"
  printf "set_var EASYRSA_REQ_ORG \"%s\"\n" "$EASYRSA_REQ_ORG"
  printf "set_var EASYRSA_REQ_EMAIL \"%s\"\n" "$EASYRSA_REQ_EMAIL"
  printf "set_var EASYRSA_REQ_OU \"%s\"\n" "$EASYRSA_REQ_OU"
  printf "set_var EASYRSA_ALGO \"%s\"\n" "$EASYRSA_ALGO"
  printf "set_var EASYRSA_DIGEST \"%s\"\n" "$EASYRSA_DIGEST"
  printf "set_var EASYRSA_KEY_SIZE \"%s\"\n" "$EASYRSA_KEY_SIZE"
} >> "$VARS"

# generating the CA certificate
printf "%s | [INFO ] generating the root CA key and certificate...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
./easyrsa \
    --batch \
    --passin="pass:$EASYRSA_PASS" \
    --passout="pass:$EASYRSA_PASS" \
    build-ca

# generating a server certificate for this server
FQDN=$(hostname -f)
./generate-cert.sh "server" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
log_end "$0"
