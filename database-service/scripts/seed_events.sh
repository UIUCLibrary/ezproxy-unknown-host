#!/bin/sh
# Inserts a set of test rows into the events table covering a range of
# timestamps and hosts.  At least two rows are older than RETENTION_DAYS
# (default 7) so that check_old_events.sh has something to report on.

DB="${POSTGRES_DB:-events}"
USER="${POSTGRES_USER:-ezproxy}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

RETENTION_DAYS="${RETENTION_DAYS:-7}"

echo "Seeding test events into '${DB}' (RETENTION_DAYS=${RETENTION_DAYS})..."

psql -U "$USER" -d "$DB" <<SQL
INSERT INTO events (timestamp, url) VALUES
  -- recent rows visible to recent_events.sh (within 30 hours)
  (NOW() - INTERVAL '1 hour',
   'https://library.example.edu/catalog/book/11111'),
  (NOW() - INTERVAL '5 hours',
   'https://journals.example.org/doi/10.1000/aaa111'),
  (NOW() - INTERVAL '12 hours',
   'https://library.example.edu/databases/article/22222'),
  (NOW() - INTERVAL '20 hours',
   'https://journals.example.org/doi/10.1001/bbb222'),
  (NOW() - INTERVAL '28 hours',
   'https://ebooks.example.com/reader/vol1/chapter3'),

  -- older rows outside the 30-hour window but within RETENTION_DAYS
  (NOW() - INTERVAL '3 days',
   'https://library.example.edu/catalog/journal/33333'),
  (NOW() - INTERVAL '5 days',
   'https://research.example.net/search?q=biology'),

  -- rows that exceed RETENTION_DAYS (should be cleaned up)
  (NOW() - INTERVAL '${RETENTION_DAYS} days' - INTERVAL '1 day',
   'https://journals.example.org/doi/10.1002/ccc333'),
  (NOW() - INTERVAL '${RETENTION_DAYS} days' - INTERVAL '3 days',
   'https://databases.example.info/record?id=99999');
SQL

echo "Done. Inserted 9 test rows."
