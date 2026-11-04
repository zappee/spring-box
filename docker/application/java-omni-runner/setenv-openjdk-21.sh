#!/bin/bash -ue
# ******************************************************************************
# Set environment variables, used during the Docker image build process.
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
export IMAGE_FROM="springbox-openjdk-21-postgres-runner:$1"
export IMAGE_NAME="springbox-openjdk-21-omni-runner"
export IMAGE_AUTHOR="Arnold Somogyi <arnold.somogyi@gmail.com>"
export IMAGE_DESCRIPTION="Remal Spring Box - OpenJDK 21 Omni Runner image"
