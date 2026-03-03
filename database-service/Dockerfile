FROM alpine:3.19

# Install sqlite3
RUN apk add --no-cache sqlite

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
CMD ["tail", "-f", "/dev/null"]
