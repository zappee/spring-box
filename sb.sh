#!/bin/bash -ue
# ******************************************************************************
# Remal Spring-Box utility.
#
# Usage: sb.sh
#        sb.sh <command>
#
# Accepted values:
#    BUILD_TYPE:       slim | fat
#    PUSH_IMAGE:       true | false
#    ENVIRONMENT_FILE; remal.com.env
#
# Since:  January 2023
# Author: Arnold SOMOGYI <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold SOMOGYI All rights reserved
# ******************************************************************************
BUILD_TYPE="slim"
IMAGE_TAG="0.8.0"
PUSH_IMAGE="false"
ENVIRONMENT_FILE="remal.com..env"

WORKSPACE="${REMAL_HOME:-$(pwd)}"
COMMAND="${1:-}"

LABEL_BASE="Base;base/base"
LABEL_JAVA_11="OpenJDK 11;core/openjdk-11"
LABEL_JAVA_17="OpenJDK 17;core/openjdk-17"
LABEL_JAVA_21="OpenJDK 21;core/openjdk-21"
LABEL_JAVA_25="OpenJDK 25;core/openjdk-25"
LABEL_PKI="PKI Private Certificate Authority (CA);infrastructure/easy-rsa-pki"
LABEL_TOMCAT_9="Apache Tomcat 9;infrastructure/tomcat-9"
LABEL_FORGEROCK_DS="ForgeRock Directory Server;infrastructure/forgerock-ds"
LABEL_FORGEROCK_AM="ForgeRock Access Management;infrastructure/forgerock-am"
LABEL_HCP_VAULT="HashiCorp Vault;infrastructure/hcp-vault"
LABEL_HCP_CONSUL_21="HashiCorp Consul for Java 21;infrastructure/hcp-consul-for-java-21"
LABEL_HCP_CONSUL_25="HashiCorp Consul for Java 25;infrastructure/hcp-consul-for-java-25"
LABEL_HAZELCAST_PLATFORM="Hazelcast Platform;infrastructure/hazelcast-platform"
LABEL_PROMETHEUS="Prometheus;monitoring/prometheus"
LABEL_GRAFANA="Grafana;monitoring/grafana"
LABEL_JAVA_21_RUNNER="Java 21 Runner;application/java-21-runner"
LABEL_JAVA_21_POSTGRES_RUNNER="Java 21 with Postgres Runner;application/java-21-postgres-runner"
LABEL_JAVA_21_OMNI_RUNNER="Java-21 OMNI Runner;application/java-21-omni-runner"
LABEL_JAVA_25_RUNNER="Java 25 Runner;application/java-25-runner"
LABEL_JAVA_25_POSTGRES_RUNNER="Java 25 with Postgres Runner;application/java-25-postgres-runner"

STYLE_TASK="\e[38;5;226m"
STYLE_SUBTASK="\e[38;5;118m"
STYLE_EXECUTION_TIME="\e[38;2;124;252;0m"
STYLE_BOLD="\033[1m"
STYLE_DEFAULT="\033[0m"
SEPARATOR="--------------------------------------------------------------------------------"

# ------------------------------------------------------------------------------
# Initialize a directory used for sharing files between the container and the
# host machine.
#
# Parameters:
#    param 1: java project name
#    param 2: docker container name
# ------------------------------------------------------------------------------
function init_docker_volume {
  local java_project="$1"
  local container_name="$2"

  local jar_source_dir="$WORKSPACE/projects/$java_project/target/"

  local volume_home="$WORKSPACE/volumes/$container_name"
  local jar_dir="$volume_home/jar-to-run"
  local logs_dir="$volume_home/logs"
  local heap_dump_dir="$volume_home/heap-dump"

  printf -- "\n%b------------------------------------------------------------------------\n" "$STYLE_TASK"
  printf "initializing a Docker shared volume...\n"
  printf "     java project:   \"%s\"\n" "$java_project"
  printf "     container name: \"%s\"\n" "$container_name"
  printf "     copy jars from: \"%s\"\n" "$jar_source_dir"
  printf "     copy jars to:   \"%s\"\n" "$jar_dir"
  printf "     logs dir:       \"%s\"\n" "$logs_dir"
  printf "     heap dump dir:  \"%s\"\n" "$heap_dump_dir"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  rm -rf "${volume_home:?}/"* # to ensure this never expands to /*
  mkdir -p "$jar_dir"
  mkdir -p "$logs_dir"
  mkdir -p "$heap_dump_dir"

  rsync --archive \
        --include '*.jar' \
        --exclude '**' \
        --verbose \
        "$jar_source_dir" \
        "$jar_dir"
}

# ------------------------------------------------------------------------------
# Deploy a docker container and run it in the background.
#
# Parameters:
#    param 1: relative directory that points to the image source code
# ------------------------------------------------------------------------------
function demo_start {
  local relative_path_to_src environment_file docker_compose_file
  relative_path_to_src="$1"
  environment_file="$WORKSPACE/$relative_path_to_src/$ENVIRONMENT_FILE"
  docker_compose_file="$WORKSPACE/$relative_path_to_src/docker-compose.yml"

  printf -- "\n%b------------------------------------------------------------------------\n" "$STYLE_TASK"
  printf "starting the '%s' docker stack...\n" "Demo"
  printf "       environment-file: '%s'\n" "$environment_file"
  printf "     docker-compose.yml: '%s'\n" "$docker_compose_file"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  init_docker_volume "remal-springbox-user-service" "user-service-1"
  init_docker_volume "remal-springbox-user-service" "user-service-2"
  init_docker_volume "remal-springbox-welcome-service" "welcome-service-1"
  init_docker_volume "remal-springbox-kafka-producer" "kafka-producer-service-1"
  init_docker_volume "remal-springbox-kafka-consumer" "kafka-consumer-service-1"
  init_docker_volume "remal-springbox-hazelcast-counter" "hazelcast-counter-service-1"
  init_docker_volume "remal-springbox-hazelcast-counter" "hazelcast-counter-service-2"
  docker compose --env-file="$environment_file" -f "$docker_compose_file" up
}

# ------------------------------------------------------------------------------
# Show the logs of running Docker containers.
# ------------------------------------------------------------------------------
function docker_container_logs {
  printf -- "\n%b------------------------------------------------------------------------\n" "$STYLE_TASK"
  printf "showing the containers' logs...\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  local running_containers_number
  running_containers_number="$(docker ps -q --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$running_containers_number" -eq 0 ]; then
    printf "no running container\n"
  else
    docker ps -q --filter "label=com.remal.image.vendor=Remal" | xargs -L 1 docker logs --follow
  fi
}

# ------------------------------------------------------------------------------
# Stop and remove of all the running Remal Docker containers.
# ------------------------------------------------------------------------------
function docker_container_remove {
  printf -- "\n%b------------------------------------------------------------------------\n" "$STYLE_TASK"
  printf "stopping and removing all the Remal Docker containers...\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  local running_containers_number
  running_containers_number="$(docker ps -aq --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$running_containers_number" -eq 0 ]; then
    printf "there is no container to remove\n"
  else
    docker rm --force $(docker container ls --filter "label=com.remal.image.vendor=Remal" -a -q)
  fi
}

# ------------------------------------------------------------------------------
# Show the running docker containers' details.
# ------------------------------------------------------------------------------
function docker_container_show {
  printf "%b%s%b\n" "$STYLE_BOLD" "$SEPARATOR" "$STYLE_DEFAULT"
  printf "%b%s\n" "$STYLE_BOLD" "List of Remal Docker containers"
  printf "%b%s%b\n" "$STYLE_BOLD" "$SEPARATOR" "$STYLE_DEFAULT"

  local _running_containers_number
  _running_containers_number="$(docker ps -aq --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$_running_containers_number" -eq 0 ]; then
    printf "%s\n" "No running containers found"
  else
    docker container ls \
      --all \
      --filter "label=com.remal.image.vendor=Remal" \
      --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}" \
      | sort -k 2
  fi
}

# ------------------------------------------------------------------------------
# Calls the external Docker build script for building the Docker image.
#
# Parameters:
#    param 1: task description string
#    param 2: relative directory that points to the image source code
# ------------------------------------------------------------------------------
function docker_image_build {
  local _title="$1"
  local _relative_path_to_src="$2"

  printf "%b%s%b\n" "$STYLE_TASK" "$SEPARATOR" "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_TASK" "Building the $_title Docker image..." "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_TASK" "$SEPARATOR" "$STYLE_DEFAULT"

  docker/build.sh "$_relative_path_to_src" "$BUILD_TYPE" "$IMAGE_TAG" "$PUSH_IMAGE"
}

# ------------------------------------------------------------------------------
# Remove all the Remal Docker images.
# ------------------------------------------------------------------------------
function docker_image_remove {
  printf -- "\n%b------------------------------------------------------------------------\n" "$STYLE_TASK"
  printf "removing all the Remal Docker images...\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  docker image rm $(docker image ls --filter "label=com.remal.image.vendor=Remal" -q) || true
}

# ------------------------------------------------------------------------------
# Show of all Remal Docker images.
# ------------------------------------------------------------------------------
function docker_image_show {
  printf "%b%s%b\n" "$STYLE_BOLD" "$SEPARATOR" "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_BOLD" "List Remal Docker images" "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_BOLD" "$SEPARATOR" "$STYLE_DEFAULT"

  docker images --filter "label=com.remal.image.vendor=Remal" --format "{{.Size}}\t{{.Repository}}:{{.Tag}}\t\t{{.CreatedSince}}\t{{.ID}}" | sort -k 2
}

# ------------------------------------------------------------------------------
# Split string by delimiter and get N-th element, the name.
#
# Parameters:
#    param 1: string to split
# ------------------------------------------------------------------------------
function get_name {
  local string
  string="$1"
  cut -d';' -f1 <<<"$string" | echo "$(cat)"
}

# ------------------------------------------------------------------------------
# Split string by delimiter and get N-th element, the path.
#
# Parameters:
#    param 1: string to split
# ------------------------------------------------------------------------------
function get_path {
  local string
  string="$1"
  cut -d';' -f2 <<<"$string"
}

# ------------------------------------------------------------------------------
# Calculate and print script execution elapsed time.
#
# Arguments:
#    $1 - Start time timestamp (seconds)
# ------------------------------------------------------------------------------
function show_execution_time() {
  local start execution_time
  start="$1"
  execution_time=$(($(date +%s) - start))

  local days hours mins secs elapsed
  days=$((execution_time / 86400))
  hours=$(( (execution_time % 86400) / 3600 ))
  mins=$(( (execution_time % 3600) / 60 ))
  secs=$(( execution_time % 60 ))
  elapsed=$(printf "execution time: %d day(s) %02d hour(s) %02d minute(s) %02d second(s)" "$days" "$hours" "$mins" "$secs")

  printf "\n%b%s%b\n" "$STYLE_EXECUTION_TIME" "$SEPARATOR" "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_EXECUTION_TIME" "$elapsed" "$STYLE_DEFAULT"
  printf "%b%s%b\n" "$STYLE_EXECUTION_TIME" "$SEPARATOR" "$STYLE_DEFAULT"
}

# ------------------------------------------------------------------------------
# Show error message and exit from the script.
# ------------------------------------------------------------------------------
function show_invalid_task_error() {
  printf "Invalid task!\n"
  exit 1
}

# ------------------------------------------------------------------------------
# Show the manual.
# ------------------------------------------------------------------------------
function show_help() {
  if [ "$1" -eq 0 ]; then
    local script
    script="${0##*/}"

    printf "%bRemal Spring-Box utility.%b\n" "$STYLE_TASK" "$STYLE_DEFAULT"
    printf "   %bUsage:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "       %s <task><task>...\n\n" "$script"
    printf "   %bExamples:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      %s ab1i: builds %s and %s images and shows image details\n" "$script" "$LABEL_BASE" "$LABEL_JAVA_11"
    printf "      %s r:    remove all running Remal Docker containers\n" "$script"
    printf "      %s vl:   start the Docker stack and show the containers' log\n\n" "$script"
    printf "   %bEnvironment:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      BUILD_TYPE: %s\n" "$BUILD_TYPE"
    printf "      WORKSPACE : %s\n\n" "$WORKSPACE"
    printf "   %bTasks%b:\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      %ba:    build the %bBase%b image%b\n" "$STYLE_TASK" "$STYLE_BOLD" "$STYLE_DEFAULT$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %ba1:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_BASE")" "$STYLE_DEFAULT"
    printf "      %bb:    build of all %bCore%b images%b\n" "$STYLE_TASK" "$STYLE_BOLD" "$STYLE_DEFAULT$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %bb1:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_11")" "$STYLE_DEFAULT"
    printf "        %bb2:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_17")" "$STYLE_DEFAULT"
    printf "        %bb3:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_21")" "$STYLE_DEFAULT"
    printf "        %bb4:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_25")" "$STYLE_DEFAULT"
    printf "      %bc:    build of all %bInfrastructure%b images%b\n" "$STYLE_TASK" "$STYLE_BOLD" "$STYLE_DEFAULT$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %bc1:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_PKI")" "$STYLE_DEFAULT"
    printf "        %bc2:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_TOMCAT_9")" "$STYLE_DEFAULT"
    printf "        %bc3:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_FORGEROCK_DS")" "$STYLE_DEFAULT"
    printf "        %bc4:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_FORGEROCK_AM")" "$STYLE_DEFAULT"
    printf "        %bc5:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_HCP_VAULT")" "$STYLE_DEFAULT"
    printf "        %bc6:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_HCP_CONSUL_21")" "$STYLE_DEFAULT"
    printf "        %bc7:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_HCP_CONSUL_25")" "$STYLE_DEFAULT"
    printf "        %bc8:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_HAZELCAST_PLATFORM")" "$STYLE_DEFAULT"
    printf "      %bd:    build of all %bMonitoring%b images%b\n" "$STYLE_TASK" "$STYLE_BOLD" "$STYLE_DEFAULT$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %bd1:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_PROMETHEUS")" "$STYLE_DEFAULT"
    printf "        %bd2:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_GRAFANA")" "$STYLE_DEFAULT"
    printf "      %be:    build of all %bApplication%b images%b\n" "$STYLE_TASK" "$STYLE_BOLD" "$STYLE_DEFAULT$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %be1:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_21_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be2:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_21_POSTGRES_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be3:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_21_OMNI_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be4:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_25_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be5:   build %s image%b\n" "$STYLE_SUBTASK" "$(get_name "$LABEL_JAVA_25_POSTGRES_RUNNER")" "$STYLE_DEFAULT"
    printf "      ------------------------------------------------------------\n"
    printf "      %bstart a Docker environment%b\n" "$STYLE_TASK" "$STYLE_DEFAULT"
    printf "        %bi1:   start the 'Demo' Docker stack%b\n" "$STYLE_SUBTASK" "$STYLE_DEFAULT"
    printf "      ------------------------------------------------------------\n"
    printf "      %b%s:    %s%b\n" "$STYLE_TASK" "v" "List Remal Docker containers" "$STYLE_DEFAULT"
    printf "      %b%s:    %s%b\n" "$STYLE_TASK" "w" "List Remal Docker images" "$STYLE_DEFAULT"
    printf "      %b%s:    %s%b\n" "$STYLE_TASK" "x" "Remove all Remal Docker containers" "$STYLE_DEFAULT"
    printf "      %b%s:    %s%b\n" "$STYLE_TASK" "y" "Remove all Remal Docker images" "$STYLE_DEFAULT"
    printf "      %b%s:    %s%b\n" "$STYLE_TASK" "z" "Show logs for all Remal Docker containers" "$STYLE_DEFAULT"
    printf "\n"
    printf "%b%s%b\n" "$STYLE_BOLD" "Credits:" "$STYLE_DEFAULT"
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
# Check whether the given task can be executed or not.
#
# Parameters:
#    param 1: task list from the command line
#    param 2: id of the task to be validated
# ------------------------------------------------------------------------------
function match {
  local args id group regexp
  args=$(printf "%sz" "$1")
  id="$2";
  group=${id:0:1}
  regexp=$(printf "(%s|%s[a-z])" "$id" "$group")

  if [[ "$args" =~ $regexp ]]; then
    true
  else
    false
  fi
}

# ------------------------------------------------------------------------------
# Check whether the given task list contains an invalid task or not.
# Rules:
#    * A task is invalid if it contains only letter, e.g "a".
#    * A task is valid if it contains letter and a belonging number, e.g "a1".
#
# Parameters:
#    param 1: task list from the command line
#    param 2: id of the task to be validated
# ------------------------------------------------------------------------------
function is_task_invalid {
  local args id regexp
  args=$(printf "%sz" "$1")
  id="$2";
  regexp=$(printf ".*%s[0-9].*" "$id")

  if [[ "$args" != *"$id"* ]]; then
    # ignore because args and id are different
    false
  else
    if [[ "$args" =~ $regexp ]]; then
      false
    else
      true
    fi
  fi
}

# ------------------------------------------------------------------------------
# Main program starts here.
# ------------------------------------------------------------------------------
show_help "$#"
START=$(date +%s)

if match "$COMMAND" "a1"; then docker_image_build "$(get_name "$LABEL_BASE")" "$(get_path "$LABEL_BASE")"; fi
if match "$COMMAND" "b1"; then docker_image_build "$(get_name "$LABEL_JAVA_11")" "$(get_path "$LABEL_JAVA_11")"; fi
if match "$COMMAND" "b2"; then docker_image_build "$(get_name "$LABEL_JAVA_17")" "$(get_path "$LABEL_JAVA_17")"; fi
if match "$COMMAND" "b3"; then docker_image_build "$(get_name "$LABEL_JAVA_21")" "$(get_path "$LABEL_JAVA_21")"; fi
if match "$COMMAND" "b4"; then docker_image_build "$(get_name "$LABEL_JAVA_25")" "$(get_path "$LABEL_JAVA_25")"; fi
if match "$COMMAND" "c1"; then docker_image_build "$(get_name "$LABEL_PKI")" "$(get_path "$LABEL_PKI")"; fi
if match "$COMMAND" "c2"; then docker_image_build "$(get_name "$LABEL_TOMCAT_9")" "$(get_path "$LABEL_TOMCAT_9")"; fi
if match "$COMMAND" "c3"; then docker_image_build "$(get_name "$LABEL_FORGEROCK_DS")" "$(get_path "$LABEL_FORGEROCK_DS")"; fi
if match "$COMMAND" "c4"; then docker_image_build "$(get_name "$LABEL_FORGEROCK_AM")" "$(get_path "$LABEL_FORGEROCK_AM")"; fi
if match "$COMMAND" "c5"; then docker_image_build "$(get_name "$LABEL_HCP_VAULT")" "$(get_path "$LABEL_HCP_VAULT")"; fi
if match "$COMMAND" "c6"; then docker_image_build "$(get_name "$LABEL_HCP_CONSUL_21")" "$(get_path "$LABEL_HCP_CONSUL_21")"; fi
if match "$COMMAND" "c7"; then docker_image_build "$(get_name "$LABEL_HCP_CONSUL_25")" "$(get_path "$LABEL_HCP_CONSUL_25")"; fi
if match "$COMMAND" "c8"; then docker_image_build "$(get_name "$LABEL_HAZELCAST_PLATFORM")" "$(get_path "$LABEL_HAZELCAST_PLATFORM")"; fi
if match "$COMMAND" "d1"; then docker_image_build "$(get_name "$LABEL_PROMETHEUS")" "$(get_path "$LABEL_PROMETHEUS")"; fi
if match "$COMMAND" "d2"; then docker_image_build "$(get_name "$LABEL_GRAFANA")" "$(get_path "$LABEL_GRAFANA")"; fi
if match "$COMMAND" "e1"; then docker_image_build "$(get_name "$LABEL_JAVA_21_RUNNER")" "$(get_path "$LABEL_JAVA_21_RUNNER")"; fi
if match "$COMMAND" "e2"; then docker_image_build "$(get_name "$LABEL_JAVA_21_POSTGRES_RUNNER")" "$(get_path "$LABEL_JAVA_21_POSTGRES_RUNNER")"; fi
if match "$COMMAND" "e3"; then docker_image_build "$(get_name "$LABEL_JAVA_21_OMNI_RUNNER")" "$(get_path "$LABEL_JAVA_21_OMNI_RUNNER")"; fi
if match "$COMMAND" "e4"; then docker_image_build "$(get_name "$LABEL_JAVA_25_RUNNER")" "$(get_path "$LABEL_JAVA_25_RUNNER")"; fi
if match "$COMMAND" "e5"; then docker_image_build "$(get_name "$LABEL_JAVA_25_POSTGRES_RUNNER")" "$(get_path "$LABEL_JAVA_25_POSTGRES_RUNNER")"; fi
if match "$COMMAND" "i1"; then demo_start "projects"; fi
if match "$COMMAND" "v";  then docker_container_show; fi
if match "$COMMAND" "w";  then docker_image_show; fi
if match "$COMMAND" "x";  then docker_container_remove; fi
if match "$COMMAND" "y";  then docker_image_remove; fi
if match "$COMMAND" "z";  then docker_container_logs; fi

show_execution_time "$START"