# Cleanup Service

Deletes rows from the `events` table that are older than seven days. The
deletion runs once per day at a time controlled by the `CLEANUP_TIME`
environment variable.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `CLEANUP_TIME` | No | `02:00` | Time of day (HH:MM, 24-hour) at which the daily cleanup runs |
| `RETENTION_DAYS` | No | `7` | Number of days to retain events; rows older than this are deleted |
| `PGHOST` | No | `database` | PostgreSQL host (set automatically in docker-compose) |
| `PGDATABASE` | No | `events` | PostgreSQL database name |
| `PGUSER` | No | `ezproxy` | PostgreSQL user |
| `PGPASSWORD` | Yes | — | PostgreSQL password |

## How It Works

The container starts a shell loop that:

1. Waits for the PostgreSQL database to accept connections via `psql`.
2. Calculates how many seconds remain until `CLEANUP_TIME` (today, or
   tomorrow if that time has already passed today).
3. Sleeps until that moment.
4. Executes `DELETE FROM events WHERE timestamp < NOW() - INTERVAL '<RETENTION_DAYS> days';`
   against the PostgreSQL database over the default Docker Compose network.
5. Returns to step 2 and waits another 24 hours.

## Network

The service connects to the `database` service over the default Docker Compose
network using the standard PostgreSQL port (5432). No shared volume is required.
