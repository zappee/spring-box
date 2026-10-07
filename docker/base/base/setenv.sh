#!/bin/bash -ue
# *******************************************************************************
# Set environment variables, used during the Docker image build process.
#
# Since:  May 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# *******************************************************************************
export IMAGE_FROM="alpine:3.24.2"
export IMAGE_NAME="springbox-base"
export IMAGE_AUTHOR="Arnold Somogyi <arnold.somogyi@gmail.com>"
export IMAGE_DESCRIPTION="Remal Spring-Box - Base image"
