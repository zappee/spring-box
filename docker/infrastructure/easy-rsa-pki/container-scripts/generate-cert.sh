#!/bin/bash
# ******************************************************************************
# Server certificate generator.
# Generates SSL/TLS certificates for server, client, or dual use.
#
# Usage: generate-cert.sh <cert-type> <domain> [san]
#
# Arguments:
#   <cert-type>  The type of certificate to issue.
#                Accepted values: server | client | serverClient
#
#   <domain>     The primary fully qualified domain name (FQDN) where the
#                certificate will be deployed (e.g., pki.remal.com).
#
#   [san]        Optional Subject Alternative Names (SAN).
#                Format example: "DNS:pki.remal.com,DNS:localhost,IP:127.0.0.1"
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
# Validates script arguments and enforces usage constraints.
#
# Arguments:
#    $@: Array of all command-line arguments passed to the script.
#
# Exits:
#    1: If the argument count is less than 2 or greater than 3.
# ------------------------------------------------------------------------------
function validate_arguments() {
  if (( $# < 2 || $# > 3 )); then
    printf "%s | [ERROR] Invalid number of arguments provided.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [ERROR] Usage: %s <cert-type> <hostname> [san]\n\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${0##*/}"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Logs the initialization arguments and relevant Easy-RSA environment contexts.
#
# Arguments:
#    $1: Certificate type (e.g., server, client, serverClient)
#    $2: Target primary domain name
#    $3: Optional Subject Alternative Names (SAN) string
# ------------------------------------------------------------------------------
function show_context() {
  local script_name="${0##*/}"
  local host_fqdn
  host_fqdn=$(hostname -f 2>/dev/null || hostname)

  printf "%s | [INFO ] Generating certificate using Easy-RSA...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [INFO ] Running '%s' script on host '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_name" "$host_fqdn"

  printf "%s | [DEBUG] Context:\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]           EASYRSA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_HOME"
  printf "%s | [DEBUG]         EASYRSA_REQ_CN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_CN"
  printf "%s | [DEBUG]    EASYRSA_REQ_COUNTRY: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_COUNTRY"
  printf "%s | [DEBUG]   EASYRSA_REQ_PROVINCE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_PROVINCE"
  printf "%s | [DEBUG]       EASYRSA_REQ_CITY: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_CITY"
  printf "%s | [DEBUG]        EASYRSA_REQ_ORG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_ORG"
  printf "%s | [DEBUG]      EASYRSA_REQ_EMAIL: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_EMAIL"
  printf "%s | [DEBUG]         EASYRSA_REQ_OU: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_REQ_OU"
  printf "%s | [DEBUG]           EASYRSA_ALGO: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_ALGO"
  printf "%s | [DEBUG]         EASYRSA_DIGEST: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_DIGEST"
  printf "%s | [DEBUG]       EASYRSA_KEY_SIZE: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_KEY_SIZE"
  printf "%s | [DEBUG]           EASYRSA_PASS: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_PASS"

  printf "%s | [INFO ] Arguments for script '%s':\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$script_name"
  printf "%s | [INFO ]    Certificate Type: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$1"
  printf "%s | [INFO ]              Domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$2"
  printf "%s | [INFO ]                 SAN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${3:-}"
}

# ------------------------------------------------------------------------------
# Revokes an existing certificate for the specified domain if it exists.
#
# Arguments:
#    $1: Domain name to revoke.
#
# Returns:
#    0: If the certificate did not exist or was successfully revoked.
#    1: If the revocation command fails.
# ------------------------------------------------------------------------------
function revoke_existing_certificate() {
  local domain="$1"

  printf "%s | [DEBUG] Checking for the existence of certificate: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  if ./easyrsa verify-cert "$domain"; then
    printf "%s | [DEBUG] Active certificate found for domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
    printf "%s | [INFO ] Revoking the certificate for domain: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"

    if ! ./easyrsa --batch --passin="pass:$EASYRSA_PASS" revoke-issued "$domain"; then
      printf "%s | [ERROR] Failed to revoke certificate for domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
      return 1
    fi
  else
    printf "%s | [INFO ] No existing certificate found for domain '%s'.\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  fi
}

# ------------------------------------------------------------------------------
# Generates a Certificate Signing Request (CSR) and a private key.
# Flow Sequence: Step 1.
#
# Arguments:
#    $1: Domain name for the Common Name (CN).
#    $2: Optional Subject Alternative Names (SAN) string.
#
# Exits:
#   1 - If directories are inaccessible or Easy-RSA context shifting fails.
# ------------------------------------------------------------------------------
function generate_cert_req_and_key() {
  local domain="$1"
  local san="${2:-}"
  local work_dir="$PWD"

  printf "%s | [INFO ] Generating a certificate request and private key...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    EASYRSA_HOME: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_HOME"
  printf "%s | [DEBUG]    EASYRSA_PASS: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$EASYRSA_PASS"
  printf "%s | [DEBUG]          Domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]             SAN: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$san"
  printf "%s | [DEBUG]        Work Dir: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$work_dir"

  cd "$EASYRSA_HOME" || { println "Error: Invalid path: '%s'\n" "$EASYRSA_HOME"; exit 1; }
  revoke_existing_certificate "$domain"

  local easy_rsa_opts=(--batch --passout="pass:$EASYRSA_PASS" --req-cn="$domain")
  if [[ -n "$san" ]]; then
    printf "%s | [INFO ] Generating certificate request with SAN: '%s'...\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$san"
    easy_rsa_opts+=(--subject-alt-name="$san")
  else
    printf "%s | [INFO ] Generating certificate request without SAN...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi

  # Execute request generation loop.
  while ! ./easyrsa "${easy_rsa_opts[@]}" gen-req "$domain"; do
    wait_for_easyrsa
  done

  cd "$work_dir" || { println "Error: Failed to return to path: '%s'\n" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# Signs the generated Certificate Signing Request (CSR).
# Flow Sequence: Step 2.
#
# Arguments:
#    $1: Certificate type, accepted values: server | client | serverClient.
#    $2: Domain name of the target infrastructure.
#
# Exits:
#   1 - If directories are inaccessible or Easy-RSA workspace shifting fails.
# ------------------------------------------------------------------------------
function signing_cert_req() {
  local cert_type="$1"
  local domain="$2"
  local work_dir="$PWD"

  printf "%s | [INFO ] Signing the certificate request...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    Cert Type: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$cert_type"
  printf "%s | [DEBUG]       Domain: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]     Work Dir: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$work_dir"

  cd "$EASYRSA_HOME" || { printf "Error: Invalid path: '%s'\n" "$EASYRSA_HOME"; exit 1; }

  while ! ./easyrsa --copy-ext --batch --passin="pass:$EASYRSA_PASS" sign-req "$cert_type" "$domain"; do
    wait_for_easyrsa
  done

  cd "$work_dir" || { printf "Error: Failed to return to path: '%s'\n" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# Exports the generated certificate and key into a new PKCS#12 keystore.
#
# Arguments:
#    $1: Domain name of the certificate to export.
#
# Exits:
#    1: If directories are inaccessible or Easy-RSA workspace shifting fails.
# ------------------------------------------------------------------------------
function export_to_keystore() {
  local domain="$1"
  local work_dir="$PWD"

  cd "$EASYRSA_HOME" || { printf "Error: Invalid path: '%s'\n" "$EASYRSA_HOME"; exit 1; }

  while ! ./easyrsa --passin="pass:$EASYRSA_PASS" --passout="pass:$EASYRSA_PASS" export-p12 "$domain"; do
    wait_for_easyrsa
  done

  cd "$work_dir" || { printf "Error: Failed to return to path: '%s'\n" "$work_dir"; exit 1; }
}

# ------------------------------------------------------------------------------
# Throttles execution and issues a warning if parallel execution is detected.
#
# Easy-RSA is not designed to run multiple instances concurrently. Running
# multiple jobs in parallel causes Easy-RSA to reuse index serial numbers,
# resulting in conflicting certificates that trigger client browser errors
# (e.g., SEC_ERROR_REUSED_ISSUER_AND_SERIAL).
# ------------------------------------------------------------------------------
function wait_for_easyrsa() {
  printf "\n%s | [WARN ] Easy-RSA is currently busy. Waiting for instance lock to release...\n\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  sleep 1
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
validate_arguments "$@"
show_context "$@"
generate_cert_req_and_key "$2" "${3:-}"
signing_cert_req "$1" "$2"
export_to_keystore "$2"
import_to_keystore "ca-cert" "$EASYRSA_HOME/pki/ca.crt" "$EASYRSA_HOME/pki/private/$2.p12" "$EASYRSA_PASS"
