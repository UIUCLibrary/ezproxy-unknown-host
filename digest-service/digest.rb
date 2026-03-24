require 'pg'
require 'mail'
require 'time'

# Digest send time defaults to 06:00 if not set
DIGEST_TIME = ENV.fetch('DIGEST_TIME', '06:00')

def timestamp
  Time.now.utc.iso8601
end

def wait_for_database
  loop do
    begin
      conn = PG.connect(
        host:     ENV.fetch('PGHOST', 'database'),
        dbname:   ENV.fetch('PGDATABASE', 'events'),
        user:     ENV.fetch('PGUSER', 'ezproxy'),
        password: ENV['PGPASSWORD']
      )
      conn.close
      puts "#{timestamp} Database is ready."
      return
    rescue PG::Error => e
      puts "#{timestamp} Waiting for database: #{e.message}"
      sleep 5
    end
  end
end

def query_events(date)
  conn = PG.connect(
    host:     ENV.fetch('PGHOST', 'database'),
    dbname:   ENV.fetch('PGDATABASE', 'events'),
    user:     ENV.fetch('PGUSER', 'ezproxy'),
    password: ENV['PGPASSWORD']
  )

  result = conn.exec_params(
    "SELECT url, COUNT(*) AS occurrences
     FROM events
     WHERE timestamp >= $1::date
       AND timestamp <  $1::date + INTERVAL '1 day'
     GROUP BY url
     ORDER BY occurrences DESC, url ASC",
    [date.to_s]
  )

  rows = result.map { |row| { url: row['url'], count: row['occurrences'].to_i } }
  conn.close
  rows
end

def build_email_body(date, rows)
  pretty_date = date.strftime('%B %-d, %Y')

  if rows.empty?
    return "EZproxy daily digest for #{pretty_date}\n\nNo unknown-host events were recorded on this date.\n"
  end

  total = rows.sum { |r| r[:count] }
  lines = ["EZproxy daily digest for #{pretty_date}",
           "Total events: #{total}",
           "",
           "URL".ljust(80) + "  Count",
           "-" * 88]

  rows.each do |row|
    lines << row[:url].ljust(80) + "  #{row[:count]}"
  end

  lines.join("\n") + "\n"
end

def send_digest(date, rows)
  pretty_date = date.strftime('%B %-d, %Y')
  body_text   = build_email_body(date, rows)

  Mail.defaults do
    delivery_method :smtp,
      address:             ENV['EZPROXY_EMAIL_RELAY'],
      port:                25,
      enable_starttls_auto: false,
      ssl:                 false,
      tls:                 false
  end

  Mail.deliver do
    from    ENV['EZPROXY_EMAIL_SENDER']
    to      ENV['EZPROXY_EMAIL_TARGETS'].split(',')
    subject "EZproxy daily digest for #{pretty_date}"
    body    body_text
  end

  puts "#{timestamp} Digest email sent to #{ENV['EZPROXY_EMAIL_TARGETS']}"
end

def seconds_until(target_hhmm)
  now            = Time.now.utc
  now_seconds    = now.hour * 3600 + now.min * 60 + now.sec
  parts          = target_hhmm.split(':').map(&:to_i)
  target_seconds = parts[0] * 3600 + parts[1] * 60
  if now_seconds < target_seconds
    target_seconds - now_seconds
  else
    86400 - now_seconds + target_seconds
  end
end

puts "#{timestamp} Digest service started. Will send digest daily at #{DIGEST_TIME}."

wait_for_database

loop do
  sleep_secs = seconds_until(DIGEST_TIME)
  puts "#{timestamp} Next digest scheduled in #{sleep_secs} seconds (at #{DIGEST_TIME})."
  sleep sleep_secs

  digest_date = Date.new(Time.now.utc.year, Time.now.utc.month, Time.now.utc.day) - 1
  puts "#{timestamp} Running digest for #{digest_date}."

  begin
    rows = query_events(digest_date)
    send_digest(digest_date, rows)
  rescue => e
    puts "#{timestamp} Error sending digest: #{e.class}: #{e.message}"
    puts e.backtrace.join("\n")
  end
end
