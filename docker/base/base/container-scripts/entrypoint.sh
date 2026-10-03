#!/bin/bash -ue
# ******************************************************************************
# Remal Docker entrypoint file.
#
# Since:  January 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi All rights reserved
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
