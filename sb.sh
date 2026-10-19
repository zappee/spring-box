#!/bin/bash -ue
# ******************************************************************************
# Remal Spring Box utility.
#
# Usage: sb.sh
#        sb.sh <task><task>...
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
IMAGE_TAG="0.8.0"
ENVIRONMENT_FILE="remal.com.env"
BUILD_TYPE="slim"  #  slim | fat
PUSH_IMAGE="false" # true | false
WORKSPACE="${REMAL_HOME:-$(pwd)}"

LABEL_BASE="Base;base/base"
LABEL_JAVA_11="OpenJDK 11;core/openjdk-11"
LABEL_JAVA_17="OpenJDK 17;core/openjdk-17"
LABEL_JAVA_21="OpenJDK 21;core/openjdk-21"
LABEL_JAVA_25="OpenJDK 25;core/openjdk-25"
LABEL_PKI="PKI Private Certificate Authority (CA);infrastructure/easy-rsa-pki"
LABEL_TOMCAT_9="Apache Tomcat 9;infrastructure/tomcat-9"
LABEL_FORGEROCK_DS="ForgeRock Directory Server;infrastructure/forgerock-ds"
LABEL_FORGEROCK_AM="ForgeRock Access Management;infrastructure/forgerock-am"
LABEL_HCP_CONSUL="HashiCorp Consul;infrastructure/hcp-consul"
LABEL_HCP_VAULT="HashiCorp Vault;infrastructure/hcp-vault"
LABEL_HAZELCAST_PLATFORM="Hazelcast Platform;infrastructure/hazelcast-platform"
LABEL_PROMETHEUS="Prometheus;monitoring/prometheus"
LABEL_GRAFANA="Grafana;monitoring/grafana"
LABEL_JAVA_21_RUNNER="Java 21 Runner;application/java-21-runner"
LABEL_JAVA_21_POSTGRES_RUNNER="Java 21 with Postgres Runner;application/java-21-postgres-runner"
LABEL_JAVA_21_OMNI_RUNNER="Java 21 OMNI Runner;application/java-21-omni-runner"
LABEL_JAVA_25_RUNNER="Java 25 Runner;application/java-25-runner"
LABEL_JAVA_25_POSTGRES_RUNNER="Java 25 with Postgres Runner;application/java-25-postgres-runner"

# ------------------------------------------------------------------------------
# Initializes a shared host-to-container directory for file exchange.
#
# Creates the directory on the host machine if it does not exist and ensures
# appropriate permissions for container volume binding.
#
# Arguments:
#    $1: The name of the Java project.
#    $2: The Docker container name.
# ------------------------------------------------------------------------------
function init_docker_volume {
  local _java_project="$1"
  local _container_name="$2"
  local _jar_source_dir="$WORKSPACE/projects/$_java_project/target/"
  local _volume_home="$WORKSPACE/volumes/$_container_name"
  local _jar_dir="$_volume_home/jar-to-run"
  local _logs_dir="$_volume_home/logs"
  local _heap_dump_dir="$_volume_home/heap-dump"

  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "Initializing a Docker shared volume...\n"
  printf "   java project:   \"%s\"\n" "$_java_project"
  printf "   container name: \"%s\"\n" "$_container_name"
  printf "   copy jars from: \"%s\"\n" "$_jar_source_dir"
  printf "   copy jars to:   \"%s\"\n" "$_jar_dir"
  printf "   logs dir:       \"%s\"\n" "$_logs_dir"
  printf "   heap dump dir:  \"%s\"\n" "$_heap_dump_dir"
  printf "%s%b\n" "$_separator" "$_style_reset"

  rm -rf "${_volume_home:?}/"* # to ensure this never expands to /*
  mkdir -p "$_jar_dir" "$_logs_dir" "$_heap_dump_dir"
  rsync --archive \
        --include '*.jar' \
        --exclude '**' \
        --verbose \
        "$_jar_source_dir" \
        "$_jar_dir"
}

# ------------------------------------------------------------------------------
# Start the demo Docker stack in the background.
#
# Arguments:
#    $1: Path to the directory containing the source code
# ------------------------------------------------------------------------------
function demo_start {
  local _relative_path_to_src="$1"
  local _environment_file="$WORKSPACE/$_relative_path_to_src/$ENVIRONMENT_FILE"
  local _compose_file="$WORKSPACE/$_relative_path_to_src/docker-compose.yml"

  printf "%s\n" "Starting the Demo Docker stack in the background..."
  printf "   environment file: %s\n" "$_environment_file"
  printf "   docker-compose:   %s\n" "$_compose_file"

  init_docker_volume "springbox-user-service" "user-service-1"
  init_docker_volume "springbox-user-service" "user-service-2"
  init_docker_volume "springbox-welcome-service" "welcome-service-1"
  init_docker_volume "springbox-kafka-producer" "kafka-producer-service-1"
  init_docker_volume "springbox-kafka-consumer" "kafka-consumer-service-1"
  init_docker_volume "springbox-hazelcast-counter" "hazelcast-counter-service-1"
  init_docker_volume "springbox-hazelcast-counter" "hazelcast-counter-service-2"
  docker compose --env-file="$_environment_file" -f "$_compose_file" up
}

# ------------------------------------------------------------------------------
# Show logs of running Docker containers.
# ------------------------------------------------------------------------------
function docker_container_logs {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "Showing the container log..."
  printf "%s%b\n" "$_separator" "$_style_reset"

  local running_containers_number
  running_containers_number="$(docker ps -q --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$running_containers_number" -eq 0 ]; then
    printf "%s\n" "No running container found."
  else
    docker ps -q --filter "label=com.remal.image.vendor=Remal" | xargs -L 1 docker logs --follow
  fi
}

# ------------------------------------------------------------------------------
# Stop and remove all running Remal Docker containers.
# ------------------------------------------------------------------------------
function docker_containers_remove {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "Stopping and removing all running Remal Docker containers...."
  printf "%s%b\n" "$_separator" "$_style_reset"

  local running_containers_number
  running_containers_number="$(docker ps -aq --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$running_containers_number" -eq 0 ]; then
    printf "%s\n" "No containers found to remove."
  else
    docker container ls --filter "label=com.remal.image.vendor=Remal" -a -q | xargs -r docker rm --force

  fi
}

# ------------------------------------------------------------------------------
# Show running Docker container.
# ------------------------------------------------------------------------------
function docker_containers_list {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "List Remal Docker containers"
  printf "%s%b\n" "$_separator" "$_style_reset"

  local _running_containers_number
  _running_containers_number="$(docker ps -aq --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$_running_containers_number" -eq 0 ]; then
    printf "%s\n" "No running container found."
  else
    docker container ls \
      --all \
      --filter "label=com.remal.image.vendor=Remal" \
      --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}" \
      | column -t -s $'\t' \
      | sort -k 2
  fi
}

# ------------------------------------------------------------------------------
# Builds a Docker image using an external build _script.
#
# Arguments:
#   $1: Image name / tag identifier
#   $2: Relative path to the source directory
# ------------------------------------------------------------------------------
function docker_image_build {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "Building the %s Docker image...\n" "$(get_name "$1")"
  printf "%s%b\n" "$_separator" "$_style_reset"

  local _path_to_src
  _path_to_src=$(get_path "$1")
  docker/build.sh "$_path_to_src" "$BUILD_TYPE" "$IMAGE_TAG" "$PUSH_IMAGE"
}

# ------------------------------------------------------------------------------
# Remove all Remal Docker images.
# ------------------------------------------------------------------------------
function docker_images_remove {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "Removing all Remal Docker images..."
  printf "%s%b\n" "$_separator" "$_style_reset"

  docker image ls --filter "label=com.remal.image.vendor=Remal" -q | xargs -r docker image rm || true
}

# ------------------------------------------------------------------------------
# Show all Remal Docker images.
# ------------------------------------------------------------------------------
function docker_images_list {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "List of Remal Docker images"
  printf "%s%b\n" "$_separator" "$_style_reset"

  docker images \
    --filter "label=com.remal.image.vendor=Remal" \
    --format "{{.Size}}\t{{.Repository}}:{{.Tag}}\t{{.CreatedSince}}\t{{.ID}}" \
    | column -t -s $'\t' \
    | sort -k 2
}

# ------------------------------------------------------------------------------
# Remove all existing Docker volumes.
# ------------------------------------------------------------------------------
function docker_volumes_remove {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _separator="--------------------------------------------------------------------------------"
  printf "%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "Removing all Docker volumes..."
  printf "%s%b\n" "$_separator" "$_style_reset"

  docker volume prune -a --force
}

# ------------------------------------------------------------------------------
# Extracts the image name from a delimited label string.
#
# Arguments:
#   $1: Semicolon-delimited string (e.g., "Docker image name;/path/to/source")
#
# Outputs:
#   Writes the name component (the text before the first semicolon) to stdout.
# ------------------------------------------------------------------------------
function get_name {
  echo "${1%%;*}"
}

# ------------------------------------------------------------------------------
# Extracts the directory path from a delimited label string.
#
# Arguments:
#   $1: Semicolon-delimited string (e.g., "Docker image name;/path/to/source")
#
# Outputs:
#   Writes the path component (the text after the first semicolon) to stdout.
# ------------------------------------------------------------------------------
function get_path {
  echo "${1#*;}"
}

# ------------------------------------------------------------------------------
# Calculate and print _script execution elapsed time.
#
# Arguments:
#    $1: Start time timestamp (seconds)
#    $2: User input
# ------------------------------------------------------------------------------
function show_execution_time() {
  # exit if the 2nd parameter is not set
  if [ -z "${2:-}" ] || [ "$2" -eq 0 ]; then return 0; fi

  local execution_time=$(($(date +%s) - "$1"))
  local days hours mins secs elapsed
  days=$((execution_time / 86400))
  hours=$(( (execution_time % 86400) / 3600 ))
  mins=$(( (execution_time % 3600) / 60 ))
  secs=$(( execution_time % 60 ))
  elapsed=$(printf "execution time: %d day(s) %02d hour(s) %02d minute(s) %02d second(s)" "$days" "$hours" "$mins" "$secs")

  local _style_reset="\033[0m"
  local _style_text="\e[38;2;124;252;0m"
  local _separator="--------------------------------------------------------------------------------"
  printf "\n%b%s\n" "$_style_text" "$_separator"
  printf "%s\n" "$elapsed"
  printf "%s%b\n" "$_separator" "$_style_reset"
}

# ------------------------------------------------------------------------------
# Display help and usage manual.
#
# Arguments:
#    $1: User input
# ------------------------------------------------------------------------------
function show_help() {
  if [ "$1" -eq 0 ]; then
    local _script="${0##*/}"

    local _style_default="\033[0m"
    local _style_bold="\033[1m"

    printf "%bRemal Spring Box utility.%b\n" "$_style_bold" "$_style_default"
    printf "Usage:\n"
    printf "   %s <task-id><task-id>...\n\n" "$_script"
    printf "Examples:\n"
    printf "   %s y       Remove all Remal images\n" "$_script"
    printf "   %s i1z     Start the Demo stack (i1) + Show the container log (z)\n" "$_script"
    printf "   %s be4w    Build Core images (b) + build %s image (e4) + List Remal images (w)\n\n" "$_script" "$(get_name "$LABEL_JAVA_25_RUNNER")"
    printf "Environment:\n"
    printf "   BUILD_TYPE: %s\n" "$BUILD_TYPE"
    printf "   WORKSPACE:  %s\n\n" "$WORKSPACE"
    printf "Tasks:\n"
    print_task "a" "Base"
    print_subtask "a1" "$(get_name $LABEL_BASE)"
    print_task "b" "Core"
    print_subtask "b1" "$(get_name "$LABEL_JAVA_11")"
    print_subtask "b2" "$(get_name "$LABEL_JAVA_17")"
    print_subtask "b3" "$(get_name "$LABEL_JAVA_21")"
    print_subtask "b4" "$(get_name "$LABEL_JAVA_25")"
    print_task "c" "Infrastructure"
    print_subtask "c1" "$(get_name "$LABEL_PKI")"
    print_subtask "c2" "$(get_name "$LABEL_TOMCAT_9")"
    print_subtask "c3" "$(get_name "$LABEL_FORGEROCK_DS")"
    print_subtask "c4" "$(get_name "$LABEL_FORGEROCK_AM")"
    print_subtask "c5" "$(get_name "$LABEL_HCP_CONSUL")"
    print_subtask "c6" "$(get_name "$LABEL_HCP_VAULT")"
    print_subtask "c7" "$(get_name "$LABEL_HAZELCAST_PLATFORM")"
    print_task "d" "Monitoring"
    print_subtask "d1" "$(get_name "$LABEL_PROMETHEUS")"
    print_subtask "d2" "$(get_name "$LABEL_GRAFANA")"
    print_task "e" "Application"
    print_subtask "e1" "$(get_name "$LABEL_JAVA_21_RUNNER")"
    print_subtask "e2" "$(get_name "$LABEL_JAVA_21_POSTGRES_RUNNER")"
    print_subtask "e3" "$(get_name "$LABEL_JAVA_21_OMNI_RUNNER")"
    print_subtask "e4" "$(get_name "$LABEL_JAVA_25_RUNNER")"
    print_subtask "e5" "$(get_name "$LABEL_JAVA_25_POSTGRES_RUNNER")"
    print_task_full_name "s" "start Docker environment"
    print_subtask "s1" "Demo Docker stack"
    print_task_full_name "u" "List Remal Docker containers"
    print_task_full_name "v" "List Remal Docker images"
    print_task_full_name "w" "Remove all Remal Docker containers"
    print_task_full_name "x" "Remove all Remal Docker images"
    print_task_full_name "y" "Remove all Docker Volumes"
    print_task_full_name "z" "Show running container logs"
    printf "\n%s\n" "Credits:"
    printf "  %s\n" "Contact:   arnold.somogyi@gmail.com"
    printf "  %s\n\n" "Copyright: Copyright (c) 2020-2026 Remal Software"
    printf "  %s\n" "This work is licensed under the Creative Commons Attribution-"
    printf "  %s\n" "NonCommercial 4.0 International License. To view a copy of this license,"
    printf "  %s\n\n" "visit: https://creativecommons.org"
    printf "  %s\n" "You are free to share and adapt the material for personal or hobby"
    printf "  %s\n" "purposes, provided you give appropriate credit and do not use the material"
    printf "  %s\n" "for commercial gain."
  fi
}

# ------------------------------------------------------------------------------
# Displays a task item formatted with ANSI colors.
#
# Arguments:
#    $1: Task identifier code (e.g., "a", "b")
#    $2: Descriptive name of the task
# ------------------------------------------------------------------------------
function print_task() {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _style_bold="${_style_text}\033[1m"
  printf "   %b%s%b:  build of all %b%s%b images%b\n" "$_style_bold" "$1" "$_style_text" "$_style_bold" "$2" "$_style_text" "$_style_reset"
}

# ------------------------------------------------------------------------------
# Displays a task item with pre-defined task name formatted with ANSI colors.
#
# Arguments:
#    $1: Task identifier code (e.g., "a", "b")
#    $2: Task full name
# ------------------------------------------------------------------------------
function print_task_full_name() {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;226m"
  local _style_bold="${_style_text}\033[1m"
  printf "   %b%s%b:  %b%s%b%b\n" "$_style_bold" "$1" "$_style_text" "$_style_bold" "$2" "$_style_text" "$_style_reset"
}

# ------------------------------------------------------------------------------
# Displays a subtask item formatted with ANSI colors.
#
# Arguments:
#    $1: Subtask identifier code (e.g., "a1", "b2")
#    $2: Descriptive name of the subtask
# ------------------------------------------------------------------------------
function print_subtask() {
  local _style_reset="\033[0m"
  local _style_text="\e[38;5;118m"
  local _style_bold="${_style_text}\033[1m"
  printf "      %b%s%b:  build %b%s%b image%b\n" "$_style_bold" "$1" "$_style_text" "$_style_bold" "$2" "$_style_text" "$_style_reset"
}

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
show_help "$#"
START_TIME=$(date +%s)
TASKS="${1:-}"

# parse and expand the task string from left to right
FINAL_TASK_LIST=()
while [ -n "$TASKS" ]; do
  # check if the remaining string starts with a letter followed by numbers (e.g., a1, c25)
  if [[ "$TASKS" =~ ^([a-z][0-9]+) ]]; then
    TOKEN="${BASH_REMATCH[1]}"
  else
    TOKEN="${TASKS:0:1}"
  fi

  # expand group tokens into individual tasks
  case "$TOKEN" in
    a) FINAL_TASK_LIST+=( "a1" ) ;;
    b) FINAL_TASK_LIST+=( "b1" "b2" "b3" "b4" ) ;;
    c) FINAL_TASK_LIST+=( "c1" "c2" "c3" "c4" "c5" "c6" "c7" ) ;;
    d) FINAL_TASK_LIST+=( "d1" "d2" ) ;;
    e) FINAL_TASK_LIST+=( "e1" "e2" "e3" "e4" "e5" ) ;;
    s) FINAL_TASK_LIST+=( "s1" ) ;;
    *) FINAL_TASK_LIST+=( "$TOKEN" ) ;; # single tasks (v, w) or explicit subtasks (b1, c2)
  esac

  # remove the processed token
  TASKS="${TASKS#"$TOKEN"}"
done

# 2) loop through the final task list and execute them
for TASK in "${FINAL_TASK_LIST[@]}"; do
  case "$TASK" in
    a1) docker_image_build "$LABEL_BASE" ;;
    b1) docker_image_build "$LABEL_JAVA_11" ;;
    b2) docker_image_build "$LABEL_JAVA_17" ;;
    b3) docker_image_build "$LABEL_JAVA_21" ;;
    b4) docker_image_build "$LABEL_JAVA_25" ;;
    c1) docker_image_build "$LABEL_PKI" ;;
    c2) docker_image_build "$LABEL_TOMCAT_9" ;;
    c3) docker_image_build "$LABEL_FORGEROCK_DS" ;;
    c4) docker_image_build "$LABEL_FORGEROCK_AM" ;;
    c5) docker_image_build "$LABEL_HCP_CONSUL" ;;
    c6) docker_image_build "$LABEL_HCP_VAULT" ;;
    c7) docker_image_build "$LABEL_HAZELCAST_PLATFORM" ;;
    d1) docker_image_build "$LABEL_PROMETHEUS" ;;
    d2) docker_image_build "$LABEL_GRAFANA" ;;
    e1) docker_image_build "$LABEL_JAVA_21_RUNNER" ;;
    e2) docker_image_build "$LABEL_JAVA_21_POSTGRES_RUNNER" ;;
    e3) docker_image_build "$LABEL_JAVA_21_OMNI_RUNNER" ;;
    e4) docker_image_build "$LABEL_JAVA_25_RUNNER" ;;
    e5) docker_image_build "$LABEL_JAVA_25_POSTGRES_RUNNER" ;;
    s1) demo_start "projects" ;;
    u)  docker_containers_list ;;
    v)  docker_images_list ;;
    w)  docker_containers_remove ;;
    x)  docker_images_remove ;;
    y)  docker_volumes_remove ;;
    z)  docker_container_logs ;;
    *)  echo "Warning: Skipped unknown task '$TASK'" ;;
  esac
done

show_execution_time "$START_TIME" "$#"
