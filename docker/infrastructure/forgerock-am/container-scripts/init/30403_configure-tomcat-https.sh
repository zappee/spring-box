#!/bin/bash -ue
# ******************************************************************************
# Apache Tomcat HTTPS/SSL configuration script.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ------------------------------------------------------------------------------
# Configuring Tomcat using SSL.
# ------------------------------------------------------------------------------
function tomcat_configuration() {
  local fqdn
  fqdn="$1"

  local keystore_file keystore_password
  keystore_file="/tmp/$fqdn.p12"
  keystore_password="changeit"

  printf "%s | [INFO]  configuring tomcat's SSL connector...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]       CATALINA_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$CATALINA_HOME"
  printf "%s | [DEBUG]            keystore: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_file"
  printf "%s | [DEBUG]   keystore password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$keystore_password"

  xmlstarlet edit \
    --inplace \
    --append  /Server/Service/Connector    --type elem -n "Connector" \
    --insert "/Server/Service/Connector[last()]" -t attr -n "port" -v "443" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "protocol" -v "org.apache.coyote.http11.Http11NioProtocol" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "maxThreads" -v "200" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "SSLEnabled" -v "true" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "scheme" -v "https" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "secure" -v "true" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "keystoreFile" -v "$keystore_file" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "keystoreType" -v "PKCS12" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "keystorePass" -v "$keystore_password" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "clientAuth" -v "false" \
    --insert "/Server/Service/Connector[@port='443']" -t attr -n "sslProtocol" -v "TLS" \
    "$CATALINA_HOME/conf/server.xml"
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
FQDN=$(hostname -f)
KEYSTORE_HOME="/tmp"
KEYSTORE_FILE="$FQDN.p12"

generate_certificate "server" "$FQDN" "DNS:$FQDN,DNS:localhost,IP:127.0.0.1"
copy_from_remote_machine "$PKI_HOST" "$SSH_USER" "$SSH_PASSWORD" "/opt/easy-rsa/pki/private/$KEYSTORE_FILE" "$KEYSTORE_HOME"
tomcat_configuration "$FQDN"
log_end "$0"
