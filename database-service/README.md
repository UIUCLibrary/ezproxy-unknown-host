# Database Service

This directory contains the configuration for a PostgreSQL database container.

## Features

- **Database**: PostgreSQL 16
- **Table**: `events` with the following schema:
  - `id`: SERIAL PRIMARY KEY
  - `timestamp`: TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
  - `url`: TEXT NOT NULL

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `POSTGRES_DB` | No | `events` | Name of the database |
| `POSTGRES_USER` | No | `ezproxy` | PostgreSQL user |
| `POSTGRES_PASSWORD` | Yes | — | PostgreSQL password |

## Usage

The database container is automatically started with `docker compose up`. PostgreSQL listens on port 5432 on the default Docker Compose network and is accessible to other services by hostname `database`.

### Accessing the Database

To access the database from within the container:

```bash
docker compose exec database psql -U ezproxy -d events
```

### Inserting Data

```bash
docker compose exec database psql -U ezproxy -d events -c "INSERT INTO events (url) VALUES ('https://example.com');"
```

### Querying Data

```bash
docker compose exec database psql -U ezproxy -d events -c "SELECT * FROM events;"
```

### Viewing Table Schema

```bash
docker compose exec database psql -U ezproxy -d events -c "\d events"
```

## Test Scripts

The `scripts/` directory contains black-box test scripts that are copied into the
container image at `/scripts/`.  Run them with `docker compose exec`:

```bash
docker compose exec database /scripts/seed_events.sh
docker compose exec database /scripts/check_old_events.sh
docker compose exec database /scripts/recent_events.sh
```

### `seed_events.sh`

Inserts 9 test rows into the `events` table covering a variety of URLs and
timestamps:

- **5 rows within the last 30 hours** (at 1 h, 5 h, 12 h, 20 h, and 28 h) — visible to `recent_events.sh`
- **2 rows within `RETENTION_DAYS`** (at 3 days and 5 days) — not yet due for cleanup
- **2 rows older than `RETENTION_DAYS`** — should be removed by the cleanup service

Multiple rows intentionally share the same hostname so that the host-count
summary in `recent_events.sh` shows grouping behaviour.

### `check_old_events.sh`

Reports whether any rows in the `events` table are older than `RETENTION_DAYS`
(default `7`).  Prints a warning with the count and the oldest timestamp when
stale rows exist, or an OK message when none are found.

The `RETENTION_DAYS` environment variable is read from the container environment
and defaults to `7` if unset, matching the behaviour of the cleanup service.

### `recent_events.sh`

Prints two sections:

1. All individual rows whose `timestamp` falls within the last 30 hours,
   ordered from newest to oldest.
2. A count-by-host summary for those same rows, using a regex to extract the
   hostname from each URL.

## Files

- `Dockerfile`: Defines the container image based on the official `postgres:16` image
- `init.sql`: SQL script to create the `events` table, run automatically on first start
- `scripts/`: Black-box test scripts (see above)
- `README.md`: This file

## Database Persistence

The database is stored in a Docker-managed volume inside the PostgreSQL container. To remove the database and start fresh:

```bash
docker compose down -v
```

Note: The `-v` flag removes volumes, which will delete all data in the database.
