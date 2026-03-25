# frozen_string_literal: true
require 'sequel'

def wait_for_database(max_attempts: 5, delay: 2)
  attempts = 0
  begin
    attempts += 1
    Sequel.connect(
      adapter: 'postgres',
      host: ENV.delete('PGHOST'),
      database: ENV.delete('POSTGRES_DB'),
      user: ENV.delete('POSTGRES_USER'),
      password: ENV.delete('POSTGRES_PASSWORD')
    )
  rescue Sequel::DatabaseConnectionError => e
    raise if attempts >= max_attempts
    warn "Waiting for database (attempt #{attempts}/#{max_attempts}): #{e.message}"
    sleep delay
    retry
  end
end

DB = wait_for_database
