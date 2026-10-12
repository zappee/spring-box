#!/bin/bash -ue
# ******************************************************************************
# Grafana configuration.
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
. /grafana-functions.sh

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
log_start "$0"
grafana_configuration
update_grafana_password
prepare_grafana_datasource_files
create_grafana_datasources
log_end "$0"
