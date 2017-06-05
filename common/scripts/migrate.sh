#!/bin/bash -e

export COMPONENT="db"
export DB_DATA_DIR="$RUNTIME_DIR/$COMPONENT/data"
export DB_CONFIG_DIR="$CONFIG_DIR/$COMPONENT"
export LOGS_FILE="$RUNTIME_DIR/logs/$COMPONENT.log"

## Write logs of this script to component specific file
exec &> >(tee -a "$LOGS_FILE")

__validate_db_envs() {
  __process_msg "Migrating database"
  __process_msg "DB_DATA_DIR: $DB_DATA_DIR"
  __process_msg "DB_CONFIG_DIR: $DB_CONFIG_DIR"
  __process_msg "LOGS_FILE:$LOGS_FILE"
}

__copy_migrations() {
  __process_msg "Copying migrations.sql to db container"
  local migrations_host_location="$MIGRATIONS_DIR/migrations.sql"
  local migrations_container_location="$CONFIG_DIR/db/migrations.sql"
  sudo cp -vr $migrations_host_location $migrations_container_location

  __process_msg "Successfully copied migrations.sql to db container"
}

__migrate() {
  __process_msg "Running migrations"

  local migrations_location="$DB_CONFIG_DIR/migrations.sql"

  local upsert_cmd="PGHOST=$DBHOST \
    PGPORT=$DBPORT \
    PGDATABASE=$DBNAME \
    PGUSER=$DBUSERNAME \
    PGPASSWORD=$DBPASSWORD \
    psql \
    -U $DBUSERNAME \
    -d $DBNAME \
    -h $DBHOST \
    -v ON_ERROR_STOP=1 \
    -f $migrations_location"

  eval "$upsert_cmd"
}

main() {
  __process_marker "Updating database"
  __validate_db_envs
  __copy_migrations
  __migrate
}

main
