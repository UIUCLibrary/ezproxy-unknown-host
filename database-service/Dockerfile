FROM debian:bookworm-slim

# Install sqlite3
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the database
RUN mkdir -p /data

# Copy the initialization script
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /data

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Keep the container running
# Note: SQLite is file-based and doesn't run as a server.
# Access the database via 'docker compose exec database sqlite3 /data/events.db'
# or by mounting the volume to other containers that need database access.
CMD ["tail", "-f", "/dev/null"]
