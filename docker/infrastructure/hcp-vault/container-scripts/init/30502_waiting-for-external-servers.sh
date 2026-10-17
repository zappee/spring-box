#!/bin/bash -ue
# ******************************************************************************
# Orchestrates container startup dependencies by blocking execution until the
# specified target containers are fully up and ready to serve requests.
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
#  Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
wait_for_container "$PKI_HOST"
log_end "$0"
