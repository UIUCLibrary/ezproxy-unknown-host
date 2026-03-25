require 'roda'
require 'rack/cors'
require 'json'
require 'time'

require_relative 'db'

class App < Roda
  plugin :json

  origins_list = ENV['EZPROXY_CORS_ORIGINS'].split(',').map(&:strip)

  def self.timestamp
    Time.now.utc.iso8601
  end



  use Rack::Cors do
    allow do

      puts App.timestamp + " " + "CORS allowed origins: #{origins_list.inspect}"

      # Specify the origins that are allowed to access your API.
      # Use '*' to allow any origin (use with caution, generally only for public APIs).
      origins origins_list
      # origins do |source_origin, env|
     #   if origins_list.include?(source_origin)
     #     puts App.timestamp + " " + "CORS origin allowed: #{source_origin}"
     #     trueq
     #   else
     #     puts App.timestamp + " " + "CORS origin denied: #{source_origin}"
     #     false
     #   end
     # end

      # Specify which resources and headers are allowed.
      resource '*',
        headers: :any,
        methods: [:post],
        credentials: true #Allows the browser to send cookies/auth headers.

    end # end of allow
  end # end of insert_before middleware


  route do |r|

    r.is /needhost/ do
      r.post do


        puts "#{App.timestamp} Origins list: #{origins_list.inspect}"

        puts "#{App.timestamp} Received needhost POST request"

        puts "#{App.timestamp} Request headers: #{r.env.select { |k, v| k.start_with?('HTTP_') }.inspect}"

        body_contents = r.body.read
        r.body.rewind  # Rewind the body to allow reading it again later if needed

        puts "#{App.timestamp} Request body: #{body_contents}"

        data = JSON.parse(body_contents)
        url = data['url']
        # Here you would handle the URL as needed, e.g., log it or send an email
        puts "#{App.timestamp} Received URL: #{url}"

        puts "#{App.timestamp} going to insert #{url} into database\n"
        DB[:events].insert(url: url)

        puts "#{App.timestamp} inserted into database\n"

        { status: 'success', message: 'URL received' }

      end
    end
  end
end

run App.freeze.app
