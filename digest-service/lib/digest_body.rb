require 'sequel'

# This class combines logic and view into one
# if this ends up being more complex, we can split it
class DigestBody

  attr_reader :text

  # this might be redudant when using Sequel, not sure
  def wait_for_database
    loop do
      begin
        @DB = Sequel.connect(
          adapter:  :postgres,
          host:     ENV.fetch('PGHOST', 'database'),
          database:   ENV.fetch('PGDATABASE', 'events'),
          user:     ENV.fetch('PGUSER', 'ezproxy'),
          password: ENV['PGPASSWORD']
        )
        puts "#{Time.now.utc.iso8601} Database is ready."
        return @DB
      rescue Sequel::DatabaseConnectionError => e
        puts "#{Time.now.utc.iso8601} Waiting for database: #{e.message}"
        sleep 5
      end
    end
  end

  def create_event_table(rows)
    table_header  = "| #{'URL'.ljust(53)} | #{'Timestamp'.ljust(19)} |\n"
    table_header += "| #{"-" * 53} | #{'-' * 19} |\n"


    table_body = rows.map do |row|
      "| #{row[:url].ljust(53)} | #{row[:local_time].strftime('%Y-%m-%d %H:%M:%S')} |"
    end.join("\n")

    table_header + table_body
  end


  # might be more efficient to have
  # postgres do the grouping and counting,
  # but not really worried about performance atm
  def create_hostname_summary(rows)
    summary = rows.group_by { |r| URI.parse(r[:url]).host }
                  .map { |host, group| [host, group.size] }
                  .sort_by { |_, count| -count }

    table_header  = "| #{'Hostname'.ljust(28)} | #{'Count'.ljust(5)} |\n"
    table_header += "| #{"-" * 28} | #{'-' * 5} |\n"

    table_body = summary.map do |host, count|
      "| #{host.ljust(28)} | #{count.to_s.rjust(5)} |"
    end.join("\n")

    table_header + table_body
  end



  def initialize(date)

    if date.nil?
      date = Time.now.to_date
    end

    wait_for_database

    yesterdays_rows = @DB[:events].
                      where(timestamp: date..(date + 1)).
                      select_append { Sequel.lit("timestamp AT TIME ZONE 'America/Chicago' AS local_time") }.
                      order(:timestamp, :url).
                      all

    if yesterdays_rows.empty?
      @text = "EZproxy daily digest for #{date.strftime('%B %-d, %Y')}\n\nNo unknown-host events were recorded on this date.\n"
    else
      # We want a simple introduction, table with
      # all urls seen in the past day, and a summary
      # of counts by hostname (strip off protocol,path
      # and query string)


      @text =<<~EMAIL
        EZproxy daily digest for #{date.strftime('%B %-d, %Y')}

        Total events: #{yesterdays_rows.size}

        URLs
        #{create_event_table(yesterdays_rows) }

        COUNT BY HOSTNAME
        #{create_hostname_summary(yesterdays_rows) }

      EMAIL
    end # of if
  end # of initialize
end
