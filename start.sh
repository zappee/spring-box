#!/bin/bash -ue
# ******************************************************************************
# Remal Docker Image build file.
#
# Usage: $ ./start.sh
#        $ ./start.sh <command>
#
# Accepted values:
#    BUILD_TYPE:       slim | fat
#    PUSH_IMAGE:       true | false
#    ENVIRONMENT_FILE; .env.hello.com | .env.remal.com
#
# Since:  January 2023
# Author: Arnold Somogyi <arnold.somogyi@gmail.com>
#
# Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.
# ******************************************************************************
BUILD_TYPE="slim"
IMAGE_TAG="0.8.0"
PUSH_IMAGE="false"
ENVIRONMENT_FILE=".env.hello.com"

WORKSPACE="${REMAL_HOME:-$(pwd)}"
COMMAND="${1:-}"

LABEL_BASE="Base;base/base"
LABEL_JAVA_11="OpenJDK 11;core/openjdk-11"
LABEL_JAVA_17="OpenJDK 17;core/openjdk-17"
LABEL_JAVA_21="OpenJDK 21;core/openjdk-21"
LABEL_JAVA_25="OpenJDK 25;core/openjdk-25"
LABEL_PKI="Private Certificate Authority;infrastructure/easy-rsa-pki"
LABEL_TOMCAT_9="Apache Tomcat 9;infrastructure/tomcat-9"
LABEL_FORGEROCK_DS="ForgeRock Directory Server;infrastructure/forgerock-ds"
LABEL_FORGEROCK_AM="ForgeRock Access Management;infrastructure/forgerock-am"
LABEL_HCP_VAULT="HashiCorp Vault;infrastructure/hcp-vault"
LABEL_HCP_CONSUL_21="HashiCorp Consul for Java 21;infrastructure/hcp-consul-for-java-21"
LABEL_HCP_CONSUL_25="HashiCorp Consul for Java 25;infrastructure/hcp-consul-for-java-25"
LABEL_HAZELCAST_PLATFORM="Hazelcast Platform;infrastructure/hazelcast-platform"
LABEL_PROMETHEUS="Prometheus;monitoring/prometheus"
LABEL_GRAFANA="Grafana;monitoring/grafana"
LABEL_JAVA_21_RUNNER="OpenJDK 21 Runner;application/openjdk-21-runner"
LABEL_JAVA_21_POSTGRES_RUNNER="OpenJDK 21 with Postgres Runner;application/openjdk-21-postgres-runner"
LABEL_JAVA_21_OMNI_RUNNER="OpenJDK 21 OMNI Runner;application/openjdk-21-omni-runner"
LABEL_JAVA_25_RUNNER="OpenJDK 25 Runner;application/openjdk-25-runner"
LABEL_JAVA_25_POSTGRES_RUNNER="OpenJDK 25 with Postgres Runner;application/openjdk-25-postgres-runner"

COLOR_GREEN="\e[38;5;118m"
COLOR_YELLOW="\e[38;5;226m"
STYLE_BOLD="\033[1m"
STYLE_DEFAULT="\033[0m"

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

  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
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

  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
  printf "starting the '%s' docker stack...\n" "Demo"
  printf "       environment-file: '%s'\n" "$environment_file"
  printf "     docker-compose.yml: '%s'\n" "$docker_compose_file"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  init_docker_volume "spring-box-user-service" "user-service-1"
  init_docker_volume "spring-box-user-service" "user-service-2"
  init_docker_volume "spring-box-welcome-service" "welcome-service-1"
  init_docker_volume "spring-box-kafka-producer" "kafka-producer-service-1"
  init_docker_volume "spring-box-kafka-consumer" "kafka-consumer-service-1"
  init_docker_volume "spring-box-hazelcast-counter" "hazelcast-counter-service-1"
  init_docker_volume "spring-box-hazelcast-counter" "hazelcast-counter-service-2"
  docker compose --env-file="$environment_file" -f "$docker_compose_file" up
}

# ------------------------------------------------------------------------------
# Show the logs of running Docker containers.
# ------------------------------------------------------------------------------
function docker_container_logs {
  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
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
  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
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
  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
  printf "running/terminated Remal Docker containers\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  local running_containers_number
  running_containers_number="$(docker ps -aq --filter "label=com.remal.image.vendor=Remal" | wc -l)"

  if [ "$running_containers_number" -eq 0 ]; then
    printf "no running container\n"
  else
    docker container ls \
      --all \
      --filter "label=com.remal.image.vendor=Remal" \
      --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}" | sort -k 2
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
  local title="$1"
  local relative_path_to_src="$2"

  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
  printf "building '%s' docker image...\n" "$title"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  docker/build.sh "$relative_path_to_src" "$BUILD_TYPE" "$IMAGE_TAG" "$PUSH_IMAGE"
}

# ------------------------------------------------------------------------------
# Remove all the Remal Docker images.
# ------------------------------------------------------------------------------
function docker_image_remove {
  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
  printf "removing all the Remal Docker images...\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

  docker image rm $(docker image ls --filter "label=com.remal.image.vendor=Remal" -q) || true
}

# ------------------------------------------------------------------------------
# Show of all Remal Docker images.
# ------------------------------------------------------------------------------
function docker_image_show {
  printf -- "\n%b------------------------------------------------------------------------\n" "$COLOR_YELLOW"
  printf "Remal Docker images\n"
  printf -- "------------------------------------------------------------------------%b\n" "$STYLE_DEFAULT"

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
# Show the execution time of the script.
#
# Parameters:
#    param 1: start time
#    param 2: command line arguments
# ------------------------------------------------------------------------------
function show_execution_time() {
  local start execution_time
  start="$1"
  command="$2"
  execution_time=$(($(date +%s) - start))

  if [ -n "$command" ]; then
    printf "\n"
    printf "execution time: %s day %s\n" "$(($(date -d@$execution_time -u +%d)-1))" "$(date -d@$execution_time -u +%H\ hour\ %M\ min\ %S\ sec)"
  fi
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

    printf "%bRemal task runner.%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "   %bUsage:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "       %s <task><task>...\n\n" "$script"
    printf "   %bExamples:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      %s ab1i: builds '%s' and '%s' images and shows image details\n" "$script" "$LABEL_BASE" "$LABEL_JAVA_11"
    printf "      %s r:    remove all running Remal Docker containers\n" "$script"
    printf "      %s vl:   start the Docker stack and show the containers' log\n\n" "$script"
    printf "   %bEnvironment:%b\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      BUILD_TYPE: %s\n" "$BUILD_TYPE"
    printf "      WORKSPACE : %s\n\n" "$WORKSPACE"
    printf "   %bTasks%b:\n" "$STYLE_BOLD" "$STYLE_DEFAULT"
    printf "      %ba:    build the %bBase%b image%b\n" "$COLOR_YELLOW" "$STYLE_BOLD" "$STYLE_DEFAULT$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %ba1:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_BASE")" "$STYLE_DEFAULT"
    printf "      %bb:    build of all %bCore%b images%b\n" "$COLOR_YELLOW" "$STYLE_BOLD" "$STYLE_DEFAULT$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %bb1:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_11")" "$STYLE_DEFAULT"
    printf "        %bb2:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_17")" "$STYLE_DEFAULT"
    printf "        %bb3:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_21")" "$STYLE_DEFAULT"
    printf "        %bb4:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_25")" "$STYLE_DEFAULT"
    printf "      %bc:    build of all %bInfrastructure%b images%b\n" "$COLOR_YELLOW" "$STYLE_BOLD" "$STYLE_DEFAULT$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %bc1:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_PKI")" "$STYLE_DEFAULT"
    printf "        %bc2:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_TOMCAT_9")" "$STYLE_DEFAULT"
    printf "        %bc3:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_FORGEROCK_DS")" "$STYLE_DEFAULT"
    printf "        %bc4:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_FORGEROCK_AM")" "$STYLE_DEFAULT"
    printf "        %bc5:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_HCP_VAULT")" "$STYLE_DEFAULT"
    printf "        %bc6:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_HCP_CONSUL_21")" "$STYLE_DEFAULT"
    printf "        %bc7:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_HCP_CONSUL_25")" "$STYLE_DEFAULT"
    printf "        %bc8:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_HAZELCAST_PLATFORM")" "$STYLE_DEFAULT"
    printf "      %bd:    build of all %bMonitoring%b images%b\n" "$COLOR_YELLOW" "$STYLE_BOLD" "$STYLE_DEFAULT$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %bd1:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_PROMETHEUS")" "$STYLE_DEFAULT"
    printf "        %bd2:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_GRAFANA")" "$STYLE_DEFAULT"
    printf "      %be:    build of all %bApplication%b images%b\n" "$COLOR_YELLOW" "$STYLE_BOLD" "$STYLE_DEFAULT$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %be1:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_21_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be2:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_21_POSTGRES_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be3:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_21_OMNI_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be4:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_25_RUNNER")" "$STYLE_DEFAULT"
    printf "        %be5:   build %s image%b\n" "$COLOR_GREEN" "$(get_name "$LABEL_JAVA_25_POSTGRES_RUNNER")" "$STYLE_DEFAULT"
    printf "      ------------------------------------------------------------\n"
    printf "      %bstart a Docker environment%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "        %bi1:   start the 'Demo' Docker stack%b\n" "$COLOR_GREEN" "$STYLE_DEFAULT"
    printf "      ------------------------------------------------------------\n"
    printf "      %bu:    list Remal Docker images%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "      %bv:    list Remal Docker containers%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "      %bw:    show Remal Docker containers' log%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "      %bx:    remove of all Remal Docker containers%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "      %by:    remove of all Remal Docker images%b\n" "$COLOR_YELLOW" "$STYLE_DEFAULT"
    printf "\n"
    printf "Contact: arnold.somogyi@gmail.com\n"
    printf "Copyright (c) 2020-2026 Remal Software and Arnold Somogyi. All rights reserved.\n"
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

# command executors
if match "$COMMAND" "x";  then docker_container_remove; fi
if match "$COMMAND" "y";  then docker_image_remove; fi

# builder tasks
# if is_task_invalid "$COMMAND" "a"; then show_invalid_task_error; fi
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

# command executors
if match "$COMMAND" "u";  then docker_image_show; fi
if match "$COMMAND" "v";  then docker_container_show; fi

# docker runners
if match "$COMMAND" "i1"; then demo_start "projects"; fi

if match "$COMMAND" "w";  then docker_container_logs; fi

show_execution_time "$START" "$#"
printf "Bye!\n"
