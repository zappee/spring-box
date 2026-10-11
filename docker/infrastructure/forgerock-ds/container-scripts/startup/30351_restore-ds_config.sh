#!/bin/bash -ue
# ******************************************************************************
# Restore ForgeRock Directory Server configuration files.
#
# Since:  May 2023
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
if [ -n "$DS_CONFIG_RESTORE_FROM" ]; then restore_ds_config "$DS_CONFIG_RESTORE_FROM"; fi
log_end "$0"
