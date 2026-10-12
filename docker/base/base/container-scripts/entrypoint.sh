#!/bin/bash -ue
# ******************************************************************************
# Remal Spring-Box Docker image entrypoint file.
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
trap "shutdown_trap; exit" SIGINT SIGTERM SIGHUP

printf "%s | [INFO ] starting OpenSSH Daemon as a background process...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
/usr/sbin/sshd -e

if [ "$(is_first_startup)" == "true" ]; then
  printf "%s | [DEBUG] this is the first startup, so let's run some tasks before continue\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  /bin/run-parts --exit-on-error /docker.init
fi

printf "%s | [DEBUG] executing the startup scripts...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
/bin/run-parts --exit-on-error /docker.startup

set_container_up_state

# keep alive the container
# the control must be in this script otherwise the 'trap' wont work
while true; do
  tail -f /dev/null & wait ${!}
done
