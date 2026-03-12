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

## Files

- `Dockerfile`: Defines the container image based on the official `postgres:16` image
- `init.sql`: SQL script to create the `events` table, run automatically on first start
- `README.md`: This file

## Database Persistence

The database is stored in a Docker-managed volume inside the PostgreSQL container. To remove the database and start fresh:

```bash
docker compose down -v
```

Note: The `-v` flag removes volumes, which will delete all data in the database.
