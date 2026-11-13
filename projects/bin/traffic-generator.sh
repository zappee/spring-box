#!/bin/bash -ue
# ******************************************************************************
# A lightweight, dependency-free Bash load-testing tool designed to generate
# realistic, fluctuating HTTP traffic for monitoring and observability
# testing (such as Prometheus and Grafana).
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
DURATION_SECONDS=1800 # Total run time: 30 minutes

MIN_THREADS=2         # Minimum concurrent threads
MAX_THREADS=6         # Maximum concurrent threads

MIN_CALLS=1           # Minimum calls a thread makes before stopping
MAX_CALLS=5           # Maximum calls a thread makes before stopping

MIN_WAIT_MS=200       # Minimum wait between requests in milliseconds
MAX_WAIT_MS=5000      # Maximum wait between requests in milliseconds

TARGET_SHIFT_SEC=15   # How often (in seconds) the target thread count shifts

# ------------------------------------------------------------------------------
# Rest endpoint functions.
# Replace `echo "200"` with your actual `curl` calls when ready, e.g.:
#   curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14214/api/welcome/joke
#
# Output:
#    3-digit HTTP status code (e.g., 200)
# ------------------------------------------------------------------------------
call_endpoint_1()  {
  # user-service-1, get user details
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14114/api/user/zappee
}

call_endpoint_2()  {
  # user-service-2, get user details
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14124/api/user/zappee
}

call_endpoint_3()  {
  # welcome-service-1, get welcome message
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14214/api/welcome/welcome/zappee
}

call_endpoint_4()  {
  # welcome-service-1, get a joke
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14214/api/welcome/joke
}

call_endpoint_5()  {
  # hazelcast-counter-service-1, show counter value
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14514/api/counter/show/zappee
}

call_endpoint_6()  {
  # hazelcast-counter-service-1, update counter
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14514/api/counter/update/zappee
}

call_endpoint_7()  {
  # hazelcast-counter-service-2, show counter value
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14524/api/counter/show/zappee
}

call_endpoint_8()  {
  # hazelcast-counter-service-2, update counter
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14514/api/counter/update/zappee
}

call_endpoint_9()  {
  # kafka-producer-service-1, send one message
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14314/api/kafka/send-one/a1
}

call_endpoint_10() {
  # kafka-producer-service-1, send five messages
  curl -k -s --max-time 5 -o /dev/null -w "%{http_code}" https://localhost:14314/api/kafka/send-multiple/5
}


# ------------------------------------------------------------------------------
# Initialize the services by calling REST endpoints.
# ------------------------------------------------------------------------------
initialize() {
  log "INFO" "Main" "=== Initializing Services ==="

  curl -k -X POST https://localhost:14114/api/user/ \
    -H "Content-Type: application/json" \
    -d '{
      "username": "zappee",
      "firstName": "Arnold",
      "email": "arnold@gmail.com",
      "description": "Java developer"
    }'
  log "DEBUG" "Main" "Initialized user-service-1"

  # init user-service-2
  curl -k -X POST https://localhost:14124/api/user/ \
    -H "Content-Type: application/json" \
    -d '{
      "username": "zappee",
      "firstName": "Arnold",
      "email": "arnold@gmail.com",
      "description": "Java developer"
    }'
  log "DEBUG" "Main" "Initialized user-service-2"

  log "INFO" "Main" "=== Service Initialization Complete ==="
}

# ------------------------------------------------------------------------------
# Logging helper.
#
# Arguments:
#    $1: Log severity level (e.g., INFO, DEBUG, WARN, ERROR)
#    $2: Component identifier (e.g., Supervisor, Worker-1)
#    $@: Remaining arguments are joined as the log message text
# ------------------------------------------------------------------------------
log() {
  local level=$1
  local source=$2
  shift 2
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")
  printf "[%s] [%-5s] [%-12s] %s\n" "$timestamp" "$level" "$source" "$*"
}

# ------------------------------------------------------------------------------
# Generate a random integer between $1 (min) and $2 (max) inclusive.
#
# Arguments:
#    $1: Minimum integer value (inclusive)
#    $2: Maximum integer value (inclusive)
# Output:
#    A random integer between min and max.
# ------------------------------------------------------------------------------
rand_range() {
  local min=$1
  local max=$2
  local span=$(( max - min + 1 ))
  local rand_val
  rand_val=$(od -An -N2 -tu2 /dev/urandom | tr -d ' ')

  # In Bash arithmetic ($(( ... ))), 10# tells the shell to interpret the digits that follow in base 10 (decimal)
  # instead of guessing the base from leading characters.
  # 10#0 evaluates to 0
  # 10#5 evaluates to 5
  # 10#08 evaluates to 8
  # 10#42915 evaluates to 42915
  echo $(( min + (10#$rand_val % span) ))
}

# ------------------------------------------------------------------------------
# Select a method index based on cumulative weights
#
# Output:
#    The selected method index.
# ------------------------------------------------------------------------------
pick_weighted_method_index() {
  local roll
  roll=$(rand_range 1 "$TOTAL_WEIGHT")
  local cumulative=0

  for (( i=0; i<${#WEIGHTS[@]}; i++ )); do
    cumulative=$(( cumulative + WEIGHTS[i] ))
    if (( roll <= cumulative )); then
      echo "$i"
      return
    fi
  done
  echo 0
}

# ------------------------------------------------------------------------------
# Background worker loop that executes a fixed quota of weighted endpoint
# calls with randomized millisecond pauses, then exits.
#
# Arguments:
#    $1: Unique worker ID for logging (e.g., 1, 2)
#    $2: Deadline after which worker aborts
#    $3: Number of endpoint calls this worker will perform
# ------------------------------------------------------------------------------
worker_task() {
  local worker_id=$1
  local end_time=$2
  local max_iterations=$3
  local tag="Worker-${worker_id}"

  log "INFO" "$tag" "Started (PID: $BASHPID) | Assigned quota: $max_iterations calls"

  for (( iter=1; iter<=max_iterations; iter++ )); do
    if (( SECONDS >= end_time )); then
      log "WARN" "$tag" "Global ${DURATION_SECONDS}s ($(( DURATION_SECONDS / 60 ))m) timeout reached. Aborting remaining calls."
      break
    fi

    # 1. Pick a weighted random endpoint method
    local idx
    idx=$(pick_weighted_method_index)
    local chosen_method="${METHODS[$idx]}"
    local method_weight="${WEIGHTS[$idx]}"

    log "DEBUG" "$tag" "Call [$iter/$max_iterations] -> Invoking $chosen_method (weight: $method_weight)..."

    # 2. Execute the method and capture HTTP status code
    local http_status
    local curl_exit=0
    http_status=$("$chosen_method") || curl_exit=$?

    if (( curl_exit == 0 )); then
      log "INFO" "$tag" "Call [$iter/$max_iterations] <- $chosen_method [w:$method_weight] completed (HTTP $http_status)"
    else
      log "ERROR" "$tag" "Call [$iter/$max_iterations] <- $chosen_method [w:$method_weight] failed (curl exit: $curl_exit, HTTP $http_status)"
    fi

    # 3. Sleep a random duration before the next call (skip on last iteration)
    if (( iter < max_iterations && SECONDS < end_time )); then
      local wait_ms
      wait_ms=$(rand_range "$MIN_WAIT_MS" "$MAX_WAIT_MS")
      local sleep_sec
      printf -v sleep_sec "%d.%03d" $((wait_ms / 1000)) $((wait_ms % 1000))

      log "DEBUG" "$tag" "Sleeping for ${wait_ms}ms (${sleep_sec}s)..."
      sleep "$sleep_sec"
    fi
  done

  log "INFO" "$tag" "Finished quota ($max_iterations calls). Thread exiting."
}

# ------------------------------------------------------------------------------
# Trap handler for SIGINT/SIGTERM that terminates all active background worker
# processes and exits cleanly.
# ------------------------------------------------------------------------------
cleanup() {
  echo ""
  log "WARN" "Supervisor" "Interrupt signal received! Stopping ${#ACTIVE_PIDS[@]} active worker(s)..."

  if (( ${#ACTIVE_PIDS[@]} > 0 )); then
    kill "${ACTIVE_PIDS[@]}" 2>/dev/null || true
    wait "${ACTIVE_PIDS[@]}" 2>/dev/null || true
  fi

  log "INFO" "Supervisor" "All workers terminated cleanly. Exiting."
  exit 0
}

# ==============================================================================
# MAIN SUPERVISOR LOOP
# ==============================================================================

# ------------------------------------------------------------------------------
# Method priority / Weight configuration (10 to 100)
# Format: "function_name:priority_weight"
# Higher numbers = called proportionally more often (e.g., GET=90, DELETE=10)
# ------------------------------------------------------------------------------
WEIGHTED_METHODS=(
  "call_endpoint_1:95"   # Frequent: user-service-1, get user details
  "call_endpoint_2:85"   # Frequent: user-service-2, get user details
  "call_endpoint_3:90"   # Frequent: welcome-service-1, get welcome message
  "call_endpoint_4:25"   # Less frequent: welcome-service-1, get a joke
  "call_endpoint_5:60"   # hazelcast-counter-service-1, show counter value
  "call_endpoint_6:100"  # Very frequent: hazelcast-counter-service-1, update counter
  "call_endpoint_7:40"   # Occasional: hazelcast-counter-service-2, show counter value
  "call_endpoint_8:50"   # Medium: hazelcast-counter-service-2, update counter
  "call_endpoint_9:15"   # Rare: kafka-producer-service-1, send one message
  "call_endpoint_10:10"  # Very rare: kafka-producer-service-1, send five messages
)

# ------------------------------------------------------------------------------
# Main program execution.
# ------------------------------------------------------------------------------
initialize

# Parse method names and weights into parallel arrays
METHODS=()
WEIGHTS=()
TOTAL_WEIGHT=0
for entry in "${WEIGHTED_METHODS[@]}"; do
  method_name="${entry%%:*}"
  weight="${entry##*:}"
  weight="${weight//[[:space:]]/}"
  METHODS+=("$method_name")
  WEIGHTS+=("$weight")
  TOTAL_WEIGHT=$(( TOTAL_WEIGHT + weight ))
done

trap cleanup SIGINT SIGTERM

# SECONDS is a built-in internal variable maintained automatically by the Bash shell itself.
END_TIME=$(( SECONDS + DURATION_SECONDS ))
NEXT_SHIFT_TIME=0
TARGET_THREADS=$(rand_range "$MIN_THREADS" "$MAX_THREADS")
ACTIVE_PIDS=()
TOTAL_SPAWNED=0

log "INFO" "Main" "=== Starting Weighted Dynamic Traffic Generator ==="
log "INFO" "Main" "Duration: ${DURATION_SECONDS}s ($(( DURATION_SECONDS / 60 ))m) | Concurrency: ${MIN_THREADS}-${MAX_THREADS} | Calls: ${MIN_CALLS}-${MAX_CALLS} | Wait: ${MIN_WAIT_MS}-${MAX_WAIT_MS}ms"
log "INFO" "Main" "Total Weight: $TOTAL_WEIGHT"

# Print method info
for (( i=0; i<${#METHODS[@]}; i++ )); do
  tenths=$(( (WEIGHTS[i] * 1000) / TOTAL_WEIGHT ))
  pct="$(( tenths / 10 )).$(( tenths % 10 ))"
  log "INFO" "Main" "  - ${METHODS[$i]} : priority ${WEIGHTS[$i]} (~${pct}% of traffic)"
done

while (( SECONDS < END_TIME )); do
  # 1. Periodically shift the desired concurrency target up or down
  if (( SECONDS >= NEXT_SHIFT_TIME )); then
    TARGET_THREADS=$(rand_range "$MIN_THREADS" "$MAX_THREADS")
    NEXT_SHIFT_TIME=$(( SECONDS + TARGET_SHIFT_SEC ))
    remaining=$(( END_TIME - SECONDS ))
    log "INFO" "Main" "Concurrency target shifted -> Target: $TARGET_THREADS | Active: ${#ACTIVE_PIDS[@]} | Time left: ${remaining}s"
  fi

  # 2. Prune PIDs of workers that have finished their random call quota
  SURVIVING_PIDS=()
  for pid in "${ACTIVE_PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      SURVIVING_PIDS+=("$pid")
    else
      wait "$pid" 2>/dev/null || true
      log "DEBUG" "Main" "Reaped finished worker process (PID: $pid)"
    fi
  done
  ACTIVE_PIDS=("${SURVIVING_PIDS[@]}")

  # 3. Spawn new workers if active count is below the current target
  while (( ${#ACTIVE_PIDS[@]} < TARGET_THREADS && SECONDS < END_TIME )); do
    (( ++TOTAL_SPAWNED ))
    calls_for_this_worker=$(rand_range "$MIN_CALLS" "$MAX_CALLS")
    log "INFO" "Main" "Spawning Worker-${TOTAL_SPAWNED} (Quota: $calls_for_this_worker calls) | Active will be: $(( ${#ACTIVE_PIDS[@]} + 1 ))/$TARGET_THREADS"

    worker_task "$TOTAL_SPAWNED" "$END_TIME" "$calls_for_this_worker" &
    ACTIVE_PIDS+=($!)
  done
  sleep 0.2
done

log "INFO" "Main" "The ${DURATION_SECONDS}s ($(( DURATION_SECONDS / 60 ))m) limit reached. Waiting for ${#ACTIVE_PIDS[@]} remaining worker(s) to finish..."

if (( ${#ACTIVE_PIDS[@]} > 0 )); then
  wait "${ACTIVE_PIDS[@]}" 2>/dev/null || true
fi

log "INFO" "Main" "=== Traffic Generation Complete | Total Workers Spawned: $TOTAL_SPAWNED ==="
