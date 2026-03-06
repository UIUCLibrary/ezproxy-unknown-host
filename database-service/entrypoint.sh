#!/bin/sh

# Database file path
DB_FILE="/data/events.db"

# Initialize the database if it doesn't exist
if [ ! -f "$DB_FILE" ]; then
    echo "Initializing database at $DB_FILE"
    sqlite3 "$DB_FILE" < /docker-entrypoint-initdb.d/init.sql
    echo "Database initialized successfully"
else
    echo "Database already exists at $DB_FILE"
fi

# Execute the command passed to the container
exec "$@"
