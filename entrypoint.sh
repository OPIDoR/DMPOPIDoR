#!/bin/bash
set -e
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
export DISABLE_SPRING=1

wait_for_db() {
  echo "Waiting for database to be ready..."
  MAX_TRIES=10
  TRY=0
  until rails db:version > /dev/null 2>&1; do
    TRY=$((TRY+1))
    if [ "$TRY" -ge "$MAX_TRIES" ]; then
      echo "Database not ready after $MAX_TRIES tries. Exiting."
      exit 1
    fi
    echo "Database is not ready yet. Retrying in 2s..."
    sleep 2
  done
  echo "Database is ready."
}

db_exists() {
  rails db:migrate:status > /dev/null 2>&1
}

create_and_setup_db() {
  echo "Creating and setting up database:"
  echo "  - Create database"
  rails db:create
  echo "  - Load schemas"
  rails db:schema:load || { echo "Failed to load schema."; exit 1; }
  echo "  - Run migrations"
  migrate_if_needed
  echo "  - Seeds database"
  rails db:seed || { echo "Failed to seed database."; exit 1; }
}

migrate_if_needed() {
  if [ "$ENABLE_AUTO_MIGRATION" = "true" ]; then
    echo "Checking for pending migrations..."
    if rails db:abort_if_pending_migrations > /dev/null 2>&1; then
      echo "No pending migrations."
    else
      echo "Running pending migrations..."
      rails db:migrate || { echo "Migration failed."; exit 1; }
    fi
  else
    echo "ENABLE_AUTO_MIGRATION is not true, skipping migrations."
  fi
}

main() {
  wait_for_db

  echo "Checking if database exists..."
  if db_exists; then
    echo "Database exists."
    migrate_if_needed
  else
    echo "Database does NOT exist."
    create_and_setup_db
  fi

  exec "$@"
}

main "$@"
