#!/bin/bash -ue
# ******************************************************************************
# ForgeRock Access Management Server installation.
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
# ForgeRock Access Management Server installation.
# ------------------------------------------------------------------------------
function install_am() {
  local fqdn truststore trustStorePassword
  fqdn=$(hostname -f)
  truststore="/tmp/$fqdn.p12"
  trustStorePassword="changeit"

  printf "%s | [INFO ] installing ForgeRock Access Management Server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                AM_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_HOME"
  printf "%s | [DEBUG]    AM_CONFIG_TOOL_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_TOOL_HOME"
  printf "%s | [DEBUG]         AM_CONFIG_TOOL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_TOOL"
  printf "%s | [DEBUG]         AM_CONFIG_FILE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_FILE"
  printf "%s | [DEBUG]             truststore: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$truststore"
  printf "%s | [DEBUG]    truststore password: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$trustStorePassword"

  "$JAVA_HOME/bin/java" \
     -Djavax.net.ssl.trustStore="$truststore" \
     -Djavax.net.ssl.trustStorePassword="$trustStorePassword" \
     -jar "$AM_CONFIG_TOOL_HOME/$AM_CONFIG_TOOL" --file "$AM_CONFIG_FILE"
}

# ------------------------------------------------------------------------------
# Prepare the ForgeRock Access Management Server configuration file for silent
# installation.
# ------------------------------------------------------------------------------
function prepare_am_config_file() {
  local fqdn domain
  fqdn=$(hostname -f)
  domain=$(hostname -d)

  local am_url am_user_locale am_server_locale accept_licenses
  am_url="https://$fqdn"
  am_user_locale="en_US"
  am_server_locale="en_US"
  am_encryption_key="w@APsye%&&DDZszeqPWha47qMTwhQicd%C*"
  accept_licenses="true"

  local am_config_store_type am_config_store_ssl
  am_config_store_type="dirServer"
  am_config_store_ssl="SSL"

  local user_store_type user_store_ssl
  user_store_type="LDAPv3ForOpenDS"
  user_store_ssl="SSL"

  local domain_dn base_dn_config base_dn_store
  domain_dn=$(fqdn_to_ldap_dn "$domain")
  base_dn_config="ou=am-config,$domain_dn"
  base_dn_store="ou=am-identity,$domain_dn"
  
  local am_config_store_manager_dn am_user_store_manager_dn
  am_config_store_manager_dn="uid=am-config,ou=admins,$base_dn_config"
  am_user_store_manager_dn="uid=am-identity-bind-account,ou=admins,$base_dn_store"

  printf "%s | [INFO ] preparing the ForgeRock Access Management Server configuration file for silent installation...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG] 1) general settings\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                AM_HOME: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_HOME"
  printf "%s | [DEBUG]            CONFIG_FILE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_FILE"
  printf "%s | [DEBUG]                   FQDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$fqdn"
  printf "%s | [DEBUG]                 domain: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]              domain DN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain_dn"
  printf "%s | [DEBUG] 2) server settings\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]                 AM_URL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_url"
  printf "%s | [DEBUG]         DEPLOYMENT_URI: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONTEXT_ROOT"
  printf "%s | [DEBUG]               BASE_DIR: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_HOME"
  printf "%s | [DEBUG]                 LOCALE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_user_locale"
  printf "%s | [DEBUG]        PLATFORM_LOCALE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_server_locale"
  printf "%s | [DEBUG]             AM_ENC_KEY: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_encryption_key"
  printf "%s | [DEBUG]              ADMIN_PWD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_ADMIN_PASSWORD"
  printf "%s | [DEBUG]       AMLDAPUSERPASSWD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_DEFAULT_POLICY_AGENT_PASSWORD"
  printf "%s | [DEBUG]          COOKIE_DOMAIN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$domain"
  printf "%s | [DEBUG]        ACCEPT_LICENSES: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$accept_licenses"
  printf "%s | [DEBUG] 3) config store settings\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]             DATA_STORE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_config_store_type"
  printf "%s | [DEBUG]          DIRECTORY_SSL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_config_store_ssl"
  printf "%s | [DEBUG]       DIRECTORY_SERVER: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_STORE_HOST"
  printf "%s | [DEBUG]         DIRECTORY_PORT: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_STORE_PORT"
  printf "%s | [DEBUG]            ROOT_SUFFIX: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$base_dn_config"
  printf "%s | [DEBUG]            DS_DIRMGRDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_config_store_manager_dn"
  printf "%s | [DEBUG]        DS_DIRMGRPASSWD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_CONFIG_STORE_MANAGER_PASSWD"
  printf "%s | [DEBUG] 4) user store settings\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]         USERSTORE_TYPE: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$user_store_type"
  printf "%s | [DEBUG]          USERSTORE_SSL: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$user_store_ssl"
  printf "%s | [DEBUG]         USERSTORE_HOST: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_USER_STORE_HOST"
  printf "%s | [DEBUG]         USERSTORE_PORT: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_USER_STORE_PORT"
  printf "%s | [DEBUG]       USERSTORE_SUFFIX: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$base_dn_store"
  printf "%s | [DEBUG]        USERSTORE_MGRDN: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$am_user_store_manager_dn"
  printf "%s | [DEBUG]       USERSTORE_PASSWD: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$AM_USER_STORE_MANAGER_PASSWD"

  cp "$AM_CONFIG_TOOL_HOME/sampleconfiguration" "$AM_CONFIG_FILE"

  # server settings
  sed -i "/^SERVER_URL=/c\SERVER_URL=$am_url" "$AM_CONFIG_FILE"
  sed -i "/^DEPLOYMENT_URI=/c\DEPLOYMENT_URI=$AM_CONTEXT_ROOT" "$AM_CONFIG_FILE"
  sed -i "/^BASE_DIR=/c\BASE_DIR=$AM_HOME" "$AM_CONFIG_FILE"
  sed -i "/^locale=/c\locale=$am_user_locale" "$AM_CONFIG_FILE"
  sed -i "/^PLATFORM_LOCALE=/c\PLATFORM_LOCALE=$am_server_locale" "$AM_CONFIG_FILE"
  sed -i "/^AM_ENC_KEY=/c\AM_ENC_KEY=$am_encryption_key" "$AM_CONFIG_FILE"
  sed -i "/^ADMIN_PWD=/c\ADMIN_PWD=$AM_ADMIN_PASSWORD" "$AM_CONFIG_FILE"
  sed -i "/^AMLDAPUSERPASSWD=/c\#AMLDAPUSERPASSWD=$AM_DEFAULT_POLICY_AGENT_PASSWORD" "$AM_CONFIG_FILE"
  sed -i "/^COOKIE_DOMAIN=/c\COOKIE_DOMAIN=$domain" "$AM_CONFIG_FILE"
  sed -i "/^ACCEPT_LICENSES=/c\ACCEPT_LICENSES=$accept_licenses" "$AM_CONFIG_FILE"

  # config store settings
  sed -i "/^DATA_STORE=/c\DATA_STORE=$am_config_store_type" "$AM_CONFIG_FILE"
  sed -i "/^DIRECTORY_SSL=/c\DIRECTORY_SSL=$am_config_store_ssl" "$AM_CONFIG_FILE"
  sed -i "/^DIRECTORY_SERVER=/c\DIRECTORY_SERVER=$AM_CONFIG_STORE_HOST" "$AM_CONFIG_FILE"
  sed -i "/^DIRECTORY_PORT=/c\DIRECTORY_PORT=$AM_CONFIG_STORE_PORT" "$AM_CONFIG_FILE"
  sed -i "/^ROOT_SUFFIX=/c\ROOT_SUFFIX=$base_dn_config" "$AM_CONFIG_FILE"
  sed -i "/^DS_DIRMGRDN=/c\DS_DIRMGRDN=$am_config_store_manager_dn" "$AM_CONFIG_FILE"
  sed -i "/^DS_DIRMGRPASSWD=/c\DS_DIRMGRPASSWD=$AM_CONFIG_STORE_MANAGER_PASSWD" "$AM_CONFIG_FILE"

  # user store settings
  sed -i "/^#USERSTORE_TYPE=/c\USERSTORE_TYPE=$user_store_type" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_SSL=/c\USERSTORE_SSL=$user_store_ssl" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_HOST=/c\USERSTORE_HOST=$AM_USER_STORE_HOST" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_PORT=/c\USERSTORE_PORT=$AM_USER_STORE_PORT" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_SUFFIX=/c\USERSTORE_SUFFIX=$base_dn_store" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_MGRDN=/c\USERSTORE_MGRDN=$am_user_store_manager_dn" "$AM_CONFIG_FILE"
  sed -i "/^#USERSTORE_PASSWD=/c\USERSTORE_PASSWD=$AM_USER_STORE_MANAGER_PASSWD" "$AM_CONFIG_FILE"
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
log_start "$0"
AM_CONFIG_FILE="$AM_CONFIG_TOOL_HOME/config.properties"
prepare_am_config_file
install_am
log_end "$0"
