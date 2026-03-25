FROM postgres:16

COPY init.sql /docker-entrypoint-initdb.d/init.sql

COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh
