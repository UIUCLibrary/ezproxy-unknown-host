#!/bin/sh
# Displays all events added in the last 30 hours, followed by a count
# summary grouped by hostname extracted from the URL.

DB="${POSTGRES_DB:-events}"
USER="${POSTGRES_USER:-ezproxy}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

echo "=== Events from the last 30 hours in '${DB}' ==="

psql -U "$USER" -d "$DB" <<'SQL'
SELECT id,
       timestamp,
       url
FROM events
WHERE timestamp >= NOW() - INTERVAL '30 hours'
ORDER BY timestamp DESC;
SQL

echo ""
echo "=== Count by host (last 30 hours) ==="

psql -U "$USER" -d "$DB" <<'SQL'
SELECT regexp_replace(url, '^https?://([^/?#]+).*$', '\1') AS host,
       COUNT(*) AS event_count
FROM events
WHERE timestamp >= NOW() - INTERVAL '30 hours'
GROUP BY host
ORDER BY event_count DESC, host;
SQL
