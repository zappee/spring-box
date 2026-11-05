#!/bin/bash -ue
# ******************************************************************************
# Remal Docker image builder.
#
# Usage:
#    build.sh <image-source-dir>
#
#    where the source-dir must point to the directory that holds the image
#    source code
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

# ------------------------------------------------------------------------------
# Builds the Docker image using the specified configuration context.
# ------------------------------------------------------------------------------
function docker_build() {
  show_build_context
  docker build \
    --build-arg "BUILDKIT_DOCKERFILE_CHECK=skip=SecretsUsedInArgOrEnv" \
    --no-cache \
    --build-arg BUILD_TYPE="$BUILD_TYPE" \
    --build-arg IMAGE_FROM="$IMAGE_FROM" \
    --build-arg IMAGE_NAME="$IMAGE_NAME" \
    --build-arg IMAGE_TAG="$IMAGE_TAG" \
    --build-arg IMAGE_AUTHOR="$IMAGE_AUTHOR" \
    --build-arg IMAGE_DESCRIPTION="$IMAGE_DESCRIPTION" \
    --build-arg JAVA_HOME="${JAVA_HOME:-}" \
    --build-arg ALPINE_PACKAGE_NAME="${ALPINE_PACKAGE_NAME:-}" \
    --tag "$IMAGE_NAME":"$IMAGE_TAG" \
    --progress plain \
    "$IMAGE_SRC"
}

# ------------------------------------------------------------------------------
# Removes stopped containers, associated volumes, and dangling images.
# ------------------------------------------------------------------------------
function docker_prune() {
  printf "%s\n" "$SEPARATOR"
  printf "%s\n" "Removing unused Docker resources..."
  printf "%s\n" "$SEPARATOR"
  docker ps --filter status=exited --filter status=created --quiet | xargs -r docker rm --volumes
  docker image prune --force
}

# ------------------------------------------------------------------------------
# Pushes the built Docker image to the remote container registry.
# ------------------------------------------------------------------------------
function docker_push() {
  if [ "$PUSH_IMAGE" = "true" ] ; then
    printf "Pushing the image to the Docker container registry...\n"
    docker push "$IMAGE_NAME:$IMAGE_TAG"
  fi
}

# ------------------------------------------------------------------------------
# Configures the environment variables by sourcing the target lifecycle script.
# ------------------------------------------------------------------------------
function set_context() {
  local script_to_run

  if [[ -n "$SUFFIX" ]]; then
    script_to_run="${IMAGE_SRC}/setenv-${SUFFIX}.sh"
  else
    script_to_run="${IMAGE_SRC}/setenv.sh"
  fi

  # shellcheck disable=SC1090
  source "$script_to_run" "$IMAGE_TAG"
}

# ------------------------------------------------------------------------------
# Displays the build configuration metadata and arguments for the Docker image.
# ------------------------------------------------------------------------------
function show_build_context() {
  printf "Configuration details:\n"
  printf "   --- required parameters ---------------------------------------------\n"
  printf "             IMAGE_SRC: '%s'\n" "$IMAGE_SRC"
  printf "            BUILD_TYPE: '%s'\n" "$BUILD_TYPE"
  printf "            IMAGE_FROM: '%s'\n" "$IMAGE_FROM"
  printf "            IMAGE_NAME: '%s'\n" "$IMAGE_NAME"
  printf "             IMAGE_TAG: '%s'\n" "$IMAGE_TAG"
  printf "          IMAGE_AUTHOR: '%s'\n" "$IMAGE_AUTHOR"
  printf "     IMAGE_DESCRIPTION: '%s'\n" "$IMAGE_DESCRIPTION"
  printf "            PUSH_IMAGE: '%s'\n" "$PUSH_IMAGE"
  printf "   --- optional parameters ----------------------------------------------\n"
  printf "                SUFFIX: '%s'\n" "$SUFFIX"
  printf "             JAVA_HOME: '%s'\n" "${JAVA_HOME:-}"
  printf "   ALPINE_PACKAGE_NAME: '%s'\n" "${ALPINE_PACKAGE_NAME:-}"
}

# ------------------------------------------------------------------------------
# Validates the number of startup arguments passed to the script.
#
# Arguments:
#   $@: All input parameters passed to the script at initialization
# ------------------------------------------------------------------------------
function validate_arguments() {
  if (( $# < 4 || $# > 5 )); then
    printf "[ERROR] Invalid number of arguments provided.\n"
    printf "Usage: %s <src-home> <build-type> <image-tag> <push-image> [image.name-suffix]\n\n" "${0##*/}"
    exit 1
  fi
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
CURRENT_SCRIPT=$(realpath "$0")
PATH_OF_CURRENT_SCRIPT=$(dirname "$CURRENT_SCRIPT")
IMAGE_SRC="$PATH_OF_CURRENT_SCRIPT/$1"
BUILD_TYPE="$2"
IMAGE_TAG="$3"
PUSH_IMAGE="$4"
SUFFIX="${5:-}"
SEPARATOR="--------------------------------------------------------------------------------"

validate_arguments "$@"
set_context

docker_build
docker_prune
docker_push

printf "\n%s\n" "The image has been successfully built."
