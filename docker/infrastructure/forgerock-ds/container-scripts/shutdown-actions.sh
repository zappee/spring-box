#!/bin/bash -ue
# ******************************************************************************
# Back up the ForgeRock Directory Server.
#
# Since:  January 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /ds-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
if [ "$AM_IDENTITY_STORE_BACKUP" == "true" ]; then backup_ds_data "$AM_IDENTITY_STORE_NAME"; fi
if [ "$AM_CONFIG_STORE_BACKUP" == "true" ]; then backup_ds_data "$AM_CONFIG_STORE_NAME"; fi
if [ "$DS_CONFIG_BACKUP" == "true" ]; then backup_ds_config; fi
log_end "$0"
