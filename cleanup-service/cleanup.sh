#!/bin/sh

# Cleanup time defaults to 02:00 if not set
CLEANUP_TIME=${CLEANUP_TIME:-"02:00"}

# Retention period in days defaults to 7 if not set
RETENTION_DAYS=${RETENTION_DAYS:-7}

echo "Cleanup service started. Will delete events older than $RETENTION_DAYS days daily at $CLEANUP_TIME."

# Wait for the PostgreSQL database to be available before entering the main loop
until psql -c '\q' 2>/dev/null; do
    echo "Waiting for database..."
    sleep 5
done
echo "Database is ready."

while true; do
    # Calculate seconds since midnight for current time and target time
    current_seconds=$(date +%H:%M | awk -F: '{print $1*3600+$2*60}')
    target_seconds=$(echo "$CLEANUP_TIME" | awk -F: '{print $1*3600+$2*60}')

    # Sleep until the target time (today if not yet reached, tomorrow otherwise)
    if [ "$current_seconds" -lt "$target_seconds" ]; then
        sleep_seconds=$((target_seconds - current_seconds))
    else
        sleep_seconds=$((86400 - current_seconds + target_seconds))
    fi

    echo "Next cleanup scheduled in $sleep_seconds seconds (at $CLEANUP_TIME)."
    sleep "$sleep_seconds"

    echo "Running cleanup at $(date)."
    psql -c "DELETE FROM events WHERE timestamp < NOW() - INTERVAL '${RETENTION_DAYS} days';"
    echo "Cleanup completed."
done
