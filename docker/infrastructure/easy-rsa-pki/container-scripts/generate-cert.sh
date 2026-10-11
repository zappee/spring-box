#!/bin/bash
# ******************************************************************************
# Remal Certificate generator.
#
# Since:  March 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Usage: generate-cert.sh <cert-type> <domain> [san]
#    cert-type: server, client, serverClient
#
#    domain:    Name of the host machine where the certificate will be used,
#               for example pki.hello.com
#
#    san:       Subject Alternative Name of the certificate, optional
#               e.g. "DNS:pki.hello.com,DNS:localhost,IP:127.0.0.1"
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ------------------------------------------------------------------------------
# Validates the start arguments of this script.
# ------------------------------------------------------------------------------
function validate_arguments() {
  if [[ $# -gt 3 || $# -lt 2 ]]; then
    printf "%s | [ERROR] Illegal number of parameters!\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [ERROR] Usage: %s <cert-type> <hostname> [san]\n\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${0##*/}"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Show the start arguments and the relevant environment values of this script.
# ------------------------------------------------------------------------------
function show_context() {
  printf "%s | [INFO ] generating a certificate using easy-rsa...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [INFO ] running \"%s\" script on \"%s\" machine...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${0##*/}" "$(hostname -f)"
  printf "%s | [DEBUG]           EASYRSA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_HOME"
  printf "%s | [DEBUG]         EASYRSA_REQ_CN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_CN"
  printf "%s | [DEBUG]    EASYRSA_REQ_COUNTRY: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_COUNTRY"
  printf "%s | [DEBUG]   EASYRSA_REQ_PROVINCE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_PROVINCE"
  printf "%s | [DEBUG]       EASYRSA_REQ_CITY: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_CITY"
  printf "%s | [DEBUG]        EASYRSA_REQ_ORG: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_ORG"
  printf "%s | [DEBUG]      EASYRSA_REQ_EMAIL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_EMAIL"
  printf "%s | [DEBUG]         EASYRSA_REQ_OU: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_OU"
  printf "%s | [DEBUG]           EASYRSA_ALGO: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_ALGO"
  printf "%s | [DEBUG]         EASYRSA_DIGEST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_DIGEST"
  printf "%s | [DEBUG]       EASYRSA_KEY_SIZE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_KEY_SIZE"
  printf "%s | [DEBUG]           EASYRSA_PASS: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_PASS"
  printf "%s | [DEBUG] arguments of the \"%s\" script:\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${0##*/}"
  printf "%s | [DEBUG]       certificate type: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"
  printf "%s | [DEBUG]                 domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$2"
  printf "%s | [DEBUG]                    san: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${3:-}"
}

# ------------------------------------------------------------------------------
# This function verifies whether a certificate has been issued for the
# specified server.
#
# Parameters:
#    param 1: domain name of the server
# ------------------------------------------------------------------------------
function revoke_existing_certificate() {
  local domain="$1"

  printf "%s | [DEBUG] checking for the existence of the \"%s\" certificate...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  if ./easyrsa verify-cert "$domain"; then
    printf "%s | [DEBUG] the certificate for \"%s\" server has already been issued\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
    printf "%s | [INFO]  revoking the certificate for \"%s\" domain...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
    ./easyrsa --batch --passin="pass:$EASYRSA_PASS" revoke-issued "$domain"
  else
    printf "%s | [INFO]  the certificate for \"%s\" server has not been issued, continue\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  fi
}

# ------------------------------------------------------------------------------
# Step 1) Generates a certificate request and a private key for the given
# domain.
#
# Parameters:
#    param 1: domain name of the server
#    param 2: the A Subject Alternative Name (SAN) for the certificate to be
#             issued
# ------------------------------------------------------------------------------
function generate_cert_req_and_key() {
  local domain="$1"
  local san="${2:-}"
  local work_dir=$PWD

  printf "%s | [INFO ] generating a certificate request and key...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    EASYRSA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_HOME"
  printf "%s | [DEBUG]    EASYRSA_PASS: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_PASS"
  printf "%s | [DEBUG]          domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]             san: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$san"
  printf "%s | [DEBUG]        work_dir: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$work_dir"

  cd "$EASYRSA_HOME" || { println "invalid path: %s" "$EASYRSA_HOME"; exit 1; }

  revoke_existing_certificate "$domain"

  if [[ -z "${san-}"  ]]; then
    printf "%s | [DEBUG] generating a certificate request...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    while ! ./easyrsa --batch --passout="pass:$EASYRSA_PASS" --req-cn="$domain" gen-req "$domain"; do
      wait_for_easyrsa
    done
  else
    printf "%s | [DEBUG] generating a certificate request with SAN: %s...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$san"
    while ! ./easyrsa --batch --passout="pass:$EASYRSA_PASS" --req-cn="$domain" --subject-alt-name="$san" gen-req "$domain"; do
      wait_for_easyrsa
    done
  fi

  cd "$work_dir" || { println "invalid path: %s" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# Step 2) Signs the certificate request.
#
# Parameters:
#    param 1: certificate type, accepted values are server, client, serverClient
#    param 2: domain name of the server
# ------------------------------------------------------------------------------
function signing_cert_req() {
  local cert_type="$1"
  local domain="$2"
  local work_dir=$PWD

  printf "%s | [INFO ] signing the certificate request...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    cert_type: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$cert_type"
  printf "%s | [DEBUG]       domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]     work_dir: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$work_dir"

  cd "$EASYRSA_HOME" || { println "invalid path: %s" "$EASYRSA_HOME"; exit 1; }
  while ! ./easyrsa --copy-ext --batch --passin="pass:$EASYRSA_PASS" sign-req "$cert_type" "$domain"; do
    wait_for_easyrsa
  done
  cd "$work_dir" || { println "invalid path: %s" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# Create a new PKCS#12 keystore and import the certificate into it.
#
# Parameters:
#    param 1: domain name of the server
# ------------------------------------------------------------------------------
function export_to_keystore() {
  local domain="$1"
  local work_dir=$PWD

  printf "%s | [INFO ] creating a new PKCS#12 keystore and import the \"%s\" certificate into it...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  cd "$EASYRSA_HOME" || { println "invalid path: %s" "$EASYRSA_HOME"; exit 1; }
  while ! ./easyrsa --passin="pass:$EASYRSA_PASS" --passout="pass:$EASYRSA_PASS" export-p12 "$domain"; do
    wait_for_easyrsa
  done
  cd "$work_dir" || { println "invalid path: %s" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# EasyRSA is not designed to be run multiple times concurrently. Running
# multiple EasyRSA jobs in parallel cause that the 'serial number'
# is reused multiple times by EasyRSA and the certificates generated will have
# the same 'serial number'. This causes various problems, such as a
# SEC_ERROR_REUSED_ISSUER_AND_SERIAL error in the web browsers.
#
# This bash function shows an message if EasyRSA detects parallel execution.
# ------------------------------------------------------------------------------
function wait_for_easyrsa() {
  printf "\n%s | [WARN ] EasyRSA is running, wait for it to finish...\n\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  sleep 1
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
validate_arguments "$@"
show_context "$@"
generate_cert_req_and_key "$2" "${3:-}"
signing_cert_req "$1" "$2"
export_to_keystore "$2"
import_to_keystore "ca-cert" "$EASYRSA_HOME/pki/ca.crt" "$EASYRSA_HOME/pki/private/$2.p12" "$EASYRSA_PASS"
