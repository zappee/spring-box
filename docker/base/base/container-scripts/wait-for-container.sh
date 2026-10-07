#!/bin/bash -ue
# ******************************************************************************
# Script: wait-for-container.sh
#
# Description: Orchestrates container startup dependencies by blocking execution
#              until the specified target container is fully up and ready to
#              serve requests. Designed to be used as a custom container
#              entrypoint.
#
# Example:     image: springbox-consul
#              container_name: consul.${DOMAIN_NAME}
#              hostname: consul.${DOMAIN_NAME}
#              entrypoint: ["/wait-for-container.sh", "pki.${DOMAIN_NAME}"]
#
# Since:       February 2025
# Author:      Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************
. /shared.sh
wait_for_container "$1"
exec /entrypoint.sh
