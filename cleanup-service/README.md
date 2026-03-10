# Cleanup Service

Deletes rows from the `events` table that are older than seven days. The
deletion runs once per day at a time controlled by the `CLEANUP_TIME`
environment variable.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `CLEANUP_TIME` | No | `02:00` | Time of day (HH:MM, 24-hour) at which the daily cleanup runs |
| `RETENTION_DAYS` | No | `7` | Number of days to retain events; rows older than this are deleted |

## How It Works

The container starts a shell loop that:

1. Waits for the database file `/data/events.db` to become available.
2. Calculates how many seconds remain until `CLEANUP_TIME` (today, or
   tomorrow if that time has already passed today).
3. Sleeps until that moment.
4. Executes `DELETE FROM events WHERE timestamp < datetime('now', '-<RETENTION_DAYS> days');`
   against `/data/events.db` (using a 5-second busy timeout to handle concurrent writes).
5. Returns to step 2 and waits another 24 hours.

## Volume

The service expects the SQLite database to be available at `/data/events.db`.
Mount the same `sqlite-data` volume used by the `database` service.
