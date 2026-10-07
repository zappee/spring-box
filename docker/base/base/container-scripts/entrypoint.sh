#!/bin/bash -ue
# *******************************************************************************
# Remal Spring-Box Docker image entrypoint file.
#
# Since:  January 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************
. /shared.sh
trap "shutdown_trap; exit 0" SIGINT SIGTERM SIGHUP

printf "%s | [INFO ] starting OpenSSH Daemon as a background process...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
/usr/sbin/sshd -e -D &

if [ "$(is_first_startup)" = "true" ]; then
  printf "%s | [DEBUG] First startup detected, running first-time initialization tasks...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  /bin/run-parts --exit-on-error /docker.init
fi

printf "%s | [DEBUG] Executing container startup scripts...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
/bin/run-parts --exit-on-error /docker.startup

set_container_up_state
printf "%s | [INFO]  Container is fully running.\n" "$(date +"%Y-%m-%d %H:%M:%S")"

# Keep container running.
# Control must stay in this script, or the 'trap' will fail.
while true; do
  tail -f /dev/null & wait ${!}
done
