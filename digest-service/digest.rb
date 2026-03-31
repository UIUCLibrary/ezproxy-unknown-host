require 'mail'
require 'time'

require_relative 'lib/digest_body'

# having some issues where information
# is not appearing in docker logs, I suspect
# there's buffering going on. :wq
$stdout.sync = true

# Digest send time defaults to 06:00 if not set
DIGEST_TIME = ENV.fetch('DIGEST_TIME', '06:00')

def timestamp
  Time.now.utc.iso8601
end



def send_digest(date)
  pretty_date = date.strftime('%B %-d, %Y')

  digest_body = DigestBody.new(date)
  body_text   = digest_body.text

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




loop do
  sleep_secs = seconds_until(DIGEST_TIME)
  puts "#{timestamp} Next digest scheduled in #{sleep_secs} seconds (at #{DIGEST_TIME})."
  sleep sleep_secs

  digest_date = Date.new(Time.now.utc.year,
                        Time.now.utc.month,
                        Time.now.utc.day) - 1

  puts "#{timestamp} Running digest for #{digest_date}."

  begin
    send_digest(digest_date)
  rescue => e
    puts "#{timestamp} Error sending digest: #{e.class}: #{e.message}"
    puts e.backtrace.join("\n")
  end
end

@DB.close if @DB
