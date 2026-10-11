#!/bin/bash -ue
# ******************************************************************************
# Configure the Hazelcast Platform.
#
# Since:  September 2025
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /hazelcast-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
setup_hazelcast
log_end "$0"
