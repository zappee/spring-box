#!/bin/bash -ue
# ******************************************************************************
# Stop Apache Tomcat script.
#
# Since:  Jul 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
. /shared.sh
. /tomcat-functions.sh

log_start "$0"
stop_tomcat
log_end "$0"
