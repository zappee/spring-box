#!/bin/bash -ue
# ******************************************************************************
# Adding the ca.cert to Alpine linux truststore.
# Curl and other command line tools must know the root CA certificate.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
log_start "$0"

cp /tmp/ca.crt /usr/local/share/ca-certificates/
cat /usr/local/share/ca-certificates/ca.crt >> /etc/ssl/certs/ca-certificates.crt

log_end "$0"
