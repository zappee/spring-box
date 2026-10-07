#!/bin/bash -ue
# *******************************************************************************
# Set environment variables, used during the Docker image build process.
#
# Since:  March 2024
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************
export IMAGE_FROM="springbox-base:$1"
export IMAGE_NAME="springbox-openjdk-21"
export IMAGE_AUTHOR="Arnold Somogyi <arnold.somogyi@gmail.com>"
export IMAGE_DESCRIPTION="Remal Spring-Box - OpenJDK 21 image"
