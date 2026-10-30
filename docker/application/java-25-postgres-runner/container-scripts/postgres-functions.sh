#!/bin/bash -ue
# ******************************************************************************
# Helper functions for PostgreSQL database management.
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
. /shared.sh

# ------------------------------------------------------------------------------
# Creates a new PostgreSQL database, a dedicated user, and grants all necessary
# privileges. Designed for Docker container initialization.
#
# Arguments:
#    $1: Target database name to create
#    $2: Username for the new database owner
#    $3: Plaintext password for the new user
#
# Dependencies:
#   Requires root privileges to switch user (`su`) to the 'postgres' account.
# ------------------------------------------------------------------------------
function create_database_and_user() {
  local database user password
  database="$1"
  user="$2"
  password="$3"

  printf "%s | [INFO ] Creating a new database and a dedicated user...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]            database name: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$database"
  printf "%s | [DEBUG]    database owner (user): \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$user"
  printf "%s | [DEBUG]    password for the user: \"%s\"\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$password"

  /bin/su -c "psql -c \"CREATE USER $user WITH PASSWORD '$password';\"" - postgres
  /bin/su -c "psql -c \"CREATE DATABASE $database OWNER $user;\"" - postgres
  /bin/su -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $database TO $user;\"" - postgres
}

# ----------------------------------------------------------------------------
# Initialize the database.
# ------------------------------------------------------------------------------
function init_database() {
  printf "%s | [INFO ] Initializing the PostgreSQL database...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]    POSTGRES_DATA: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_DATA"

  set +e
  pg_controldata "$POSTGRES_DATA"
  local exit_code=$?
  set -e

  chown postgres:postgres -R "$POSTGRES_DATA"

  if [ $exit_code -eq 0 ]; then
    printf "%s | [INFO ] The PostgreSQL database has already been initialized.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    # step 1
    printf "%s | [INFO ] --> 1/3: Initializing the PostgreSQL database...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [DEBUG] POSTGRES_DATA: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_DATA"
    /bin/su -c "initdb -D $POSTGRES_DATA" - postgres

    # step 2
    printf "%s | [INFO ] --> 2/3: Updating the PostgreSQL database configuration...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [DEBUG] POSTGRES_LOG_DIR: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_LOG_DIR"
    printf "%s | [DEBUG] POSTGRES_CONFIG: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_CONFIG"
    mv /tmp/pg_hba.conf "$POSTGRES_DATA"
    mv /tmp/postgresql.conf "$POSTGRES_DATA"
    sed -i "s|\${POSTGRES_LOG_DIR}|$POSTGRES_LOG_DIR|g" "$POSTGRES_CONFIG"

    # step 3
    printf "%s | [INFO ] --> 3/3: Updating databases...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    start_postgres "true"
    set_database_password "$DB_ADMIN_USER" "$DB_ADMIN_PASSWORD"
    create_database_and_user "$DB_APP_DATABASE" "$DB_APP_USER" "$DB_APP_PASSWORD"
    stop_postgres
  fi
}

# ------------------------------------------------------------------------------
# Updates the password for a specified PostgreSQL database user.
#
# Arguments:
#    $1: Target username to alter
#    $2: New plaintext password for the user
#
# Dependencies:
#   Requires root privileges to switch user (`su`) to the 'postgres' account.
# ------------------------------------------------------------------------------
function set_database_password() {
  local user password
  user="$1"
  password="$2"

  printf "%s | [INFO ] Setting the password for the database user...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]        database user: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$user"
  printf "%s | [DEBUG]    password for user: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$password"

  /bin/su -c "psql -c \"ALTER USER $user PASSWORD '$password';\"" - postgres
}

# ------------------------------------------------------------------------------
# Starts the PostgreSQL database server and waits for it to become fully ready.
#
# Arguments:
#    $1: Execution trigger; must be 'true' to initiate the database startup
# ------------------------------------------------------------------------------
function start_postgres() {
  local signal
  signal="$1"

  if [ "$signal" == "true" ]; then
    local postgres_log
    postgres_log="$POSTGRES_LOG_DIR/postgresql.log"

    printf "%s | [INFO ] Starting the PostgreSQL database server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [DEBUG]     POSTGRES_DATA: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_DATA"
    printf "%s | [DEBUG]    start database: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$signal"
    printf "%s | [DEBUG]          log file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$postgres_log"

    pkill -f "$postgres_log" || true
    rm -f "$postgres_log"
    /bin/su -c "pg_ctl start -D $POSTGRES_DATA" - postgres
    tail -n +1 -F "$postgres_log" &

    wait_until_content_found "$postgres_log" "database system is ready"
    printf "%s | [INFO ] The database server has been started successfully.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  else
    printf "%s | [DEBUG] Skipping the startup of the database server.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
    printf "%s | [DEBUG] To start the database server, set 'START_DB=true' in the 'compose.yml' file.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  fi
}

# ----------------------------------------------------------------------------
# Stops the PostgreSQL database server.
# ------------------------------------------------------------------------------
function stop_postgres() {
  local postgres_log
  postgres_log="$POSTGRES_LOG_DIR/postgresql.log"

  printf "%s | [INFO ] Stopping the PostgreSQL database server...\n" "$(date +"%Y-%m-%d %H:%M:%S")"
  printf "%s | [DEBUG]     POSTGRES_DATA: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$POSTGRES_DATA"
  printf "%s | [DEBUG]          log file: '%s'\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$postgres_log"

  /bin/su -c "pg_ctl stop -D $POSTGRES_DATA" - postgres
  printf "%s | [INFO ] The PostgreSQL database server has been stopped successfully.\n" "$(date +"%Y-%m-%d %H:%M:%S")"
}
