FROM debian:bookworm-slim

# Install sqlite3
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copy the cleanup script
COPY cleanup.sh /cleanup.sh
RUN chmod +x /cleanup.sh

# Run the cleanup script
CMD ["/cleanup.sh"]
