#!/bin/bash -ue
# ******************************************************************************
# Adding the ca.cert to Alpine linux truststore.
# Curl and other command line tools must know the root CA certificate.
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

mkdir -p /usr/local/share/ca-certificates && cp /tmp/ca.crt /usr/local/share/ca-certificates/
cat /usr/local/share/ca-certificates/ca.crt >> /etc/ssl/certs/ca-certificates.crt

log_end "$0"
