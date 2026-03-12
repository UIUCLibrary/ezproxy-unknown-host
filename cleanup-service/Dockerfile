FROM debian:bookworm-slim

# Install postgresql-client
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the cleanup script
COPY cleanup.sh /cleanup.sh
RUN chmod +x /cleanup.sh

# Run the cleanup script
CMD ["/cleanup.sh"]
