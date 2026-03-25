#!/bin/sh
# Reports whether any rows in the events table are older than RETENTION_DAYS
# (default 7).  Exits with status 1 when stale rows exist, 0 when none are
# found, so the script can be used in automated checks.

DB="${POSTGRES_DB:-events}"
USER="${POSTGRES_USER:-ezproxy}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

RETENTION_DAYS="${RETENTION_DAYS:-7}"

echo "Checking for events older than ${RETENTION_DAYS} days in '${DB}'..."

result=$(psql -U "$USER" -d "$DB" -t -A <<SQL
SELECT COUNT(*) AS stale_count,
       MIN(timestamp) AS oldest_timestamp
FROM events
WHERE timestamp < NOW() - INTERVAL '${RETENTION_DAYS} days';
SQL
)

stale_count=$(echo "$result" | cut -d'|' -f1)
oldest_timestamp=$(echo "$result" | cut -d'|' -f2)

if [ "$stale_count" -gt 0 ]; then
    echo "WARNING: ${stale_count} event(s) found older than ${RETENTION_DAYS} days."
    echo "Oldest event timestamp: ${oldest_timestamp}"
    exit 1
else
    echo "OK: No events older than ${RETENTION_DAYS} days."
    exit 0
fi
