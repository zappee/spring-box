#!/bin/bash -ue
# ******************************************************************************
# Backup ForgeRock Directory Server configuration prior to container shutdown.

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
. /ds-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
if [ "$AM_IDENTITY_STORE_BACKUP" == "true" ]; then backup_ds_data "$AM_IDENTITY_STORE_NAME"; fi
if [ "$AM_CONFIG_STORE_BACKUP" == "true" ]; then backup_ds_data "$AM_CONFIG_STORE_NAME"; fi
if [ "$DS_CONFIG_BACKUP" == "true" ]; then backup_ds_config; fi
log_end "$0"
