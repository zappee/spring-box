#!/bin/bash -ue
# ******************************************************************************
# Script that blocks a Docker container from running and waits for the specified
# container to be up and ready to serve client requests. This script can be used
# as a new entrypoint of the container.
#
# For example:
#        consul:
#            image: remal-consul
#            container_name: consul.${DOMAIN_NAME}
#            hostname: consul.${DOMAIN_NAME}
#            entrypoint: ["/wait-for-container.sh", "pki.${DOMAIN_NAME}"]
#            ...
#
# Since:  February 2025
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi All rights reserved
# ******************************************************************************
. /shared.sh
wait_for_container "$1"
exec /entrypoint.sh
