#!/bin/bash -ue
# ******************************************************************************
# Apache Tomcat JVM configuration.
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
# Configuring Tomcat using SSL.
# ------------------------------------------------------------------------------
function tomcat_configuration() {
  local fqdn truststore_file truststore_password
  fqdn="$(hostname -f)"
  truststore_file="/tmp/$fqdn.p12"
  truststore_password="changeit"

  JAVA_OPTS="\
      -Djavax.net.ssl.trustStore=$truststore_file \
      -Djavax.net.ssl.trustStorePassword=$truststore_password \
      -Djavax.net.ssl.trustStoreType=PKCS12 \
      -Xms1024m \
      -Xmx1024m \
      -XX:+UseParallelGC \
      -XX:MetaspaceSize=256m \
      -XX:MaxMetaspaceSize=256m"

  printf "%s | [INFO ] configuring tomcat's JVM settings...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]            truststore: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$truststore_file"
  printf "%s | [DEBUG]   truststore password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$truststore_password"
  printf "%s | [DEBUG]             JAVA_OPTS: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$JAVA_OPTS"

  printf "JAVA_OPTS=\"%s\"" "$JAVA_OPTS" > "$CATALINA_HOME/bin/setenv.sh"
  chmod +x "$CATALINA_HOME/bin/setenv.sh"
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"
tomcat_configuration
log_end "$0"
