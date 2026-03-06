# Database Service

This directory contains the configuration for a lightweight SQLite3 database container.

## Features

- **Database**: SQLite3
- **Table**: `events` with the following schema:
  - `id`: INTEGER PRIMARY KEY AUTOINCREMENT
  - `timestamp`: DATETIME DEFAULT CURRENT_TIMESTAMP
  - `url`: TEXT NOT NULL

## Usage

The database container is automatically started with `docker compose up`. The database file is stored in a persistent volume called `sqlite-data` to ensure data persists across container restarts.

### Accessing the Database

To access the database from within the container:

```bash
docker compose exec database sqlite3 /data/events.db
```

### Inserting Data

```bash
docker compose exec database sqlite3 /data/events.db "INSERT INTO events (url) VALUES ('https://example.com');"
```

### Querying Data

```bash
docker compose exec database sqlite3 /data/events.db "SELECT * FROM events;"
```

### Viewing Table Schema

```bash
docker compose exec database sqlite3 /data/events.db ".schema events"
```

## Files

- `Dockerfile`: Defines the container image based on Debian Bookworm Slim with SQLite3
- `init.sql`: SQL script to create the events table
- `entrypoint.sh`: Initialization script that creates the database and table on first run
- `README.md`: This file

## Database Persistence

The database is stored in a Docker volume named `sqlite-data`, which persists data across container restarts and updates. To remove the database and start fresh:

```bash
docker compose down -v
```

Note: The `-v` flag removes volumes, which will delete all data in the database.
