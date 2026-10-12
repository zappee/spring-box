#!/bin/bash -ue
# ******************************************************************************
# Restore LDAP data from a backup file.
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
. /ds-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
if [ -n "$AM_CONFIG_STORE_RESTORE_FROM" ]; then restore_ds_data "$AM_CONFIG_STORE_RESTORE_FROM" "$AM_CONFIG_STORE_NAME"; fi
if [ -n "$AM_IDENTITY_STORE_RESTORE_FROM" ]; then restore_ds_data "$AM_IDENTITY_STORE_RESTORE_FROM" "$AM_IDENTITY_STORE_NAME"; fi
log_end "$0"
