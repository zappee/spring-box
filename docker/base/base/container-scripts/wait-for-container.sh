#!/bin/bash -ue
# ******************************************************************************
# Orchestrates container startup dependencies by blocking execution until the
# specified target container is fully up and ready to serve requests. Designed
# to be used as a custom container entrypoint.
#
# Example:  image: springbox-consul
#           container_name: consul.${DOMAIN_NAME}
#           hostname: consul.${DOMAIN_NAME}
#           entrypoint: ["/wait-for-container.sh", "pki.${DOMAIN_NAME}"]
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
wait_for_container "$1"
exec /entrypoint.sh
