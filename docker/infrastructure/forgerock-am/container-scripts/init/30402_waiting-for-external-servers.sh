#!/bin/bash -ue
# ******************************************************************************
# This script blocks the execution and waits for external servers to be ready to
# serve incoming requests.
#
# Since:  July 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
wait_for_container "$PKI_HOST"
wait_for_container "$AM_CONFIG_STORE_HOST"
wait_for_container "$AM_USER_STORE_HOST"
log_end "$0"
