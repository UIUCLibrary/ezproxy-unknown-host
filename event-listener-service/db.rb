# frozen_string_literal: true
require 'sequel'

DB = Sequel.connect(
        adapter: 'postgres',
        host: ENV.delete('PGHOST'),
        database: ENV.delete('POSTGRES_DB'),
        user: ENV.delete('POSTGRES_USER'),
        password: ENV.delete('POSTGRES_PASSWORD')
)
