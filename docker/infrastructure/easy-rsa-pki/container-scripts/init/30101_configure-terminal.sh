#!/bin/bash -ue
# ******************************************************************************
# Bash environment configuration in Docker environment.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
log_start "$0"
{
  printf "export %s=\"%s\"\n" "EASYRSA_HOME" "$EASYRSA_HOME"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_CN" "$EASYRSA_REQ_CN"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_COUNTRY" "$EASYRSA_REQ_COUNTRY"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_PROVINCE" "$EASYRSA_REQ_PROVINCE"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_CITY" "$EASYRSA_REQ_CITY"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_ORG" "$EASYRSA_REQ_ORG"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_EMAIL" "$EASYRSA_REQ_EMAIL"
  printf "export %s=\"%s\"\n" "EASYRSA_REQ_OU" "$EASYRSA_REQ_OU"
  printf "export %s=\"%s\"\n" "EASYRSA_ALGO" "$EASYRSA_ALGO"
  printf "export %s=\"%s\"\n" "EASYRSA_DIGEST" "$EASYRSA_DIGEST"
  printf "export %s=\"%s\"\n" "EASYRSA_KEY_SIZE" "$EASYRSA_KEY_SIZE"
  printf "export %s=\"%s\"\n" "EASYRSA_PASS" "$EASYRSA_PASS"
  printf "cd %s\n" "$EASYRSA_HOME"
} >> /etc/profile
log_end "$0"
