require 'roda'
require 'rack/cors'
require 'json'

require 'mail'

class App < Roda
  plugin :json


  use Rack::Cors do
    allow do

      origins_list = ENV['EZPROXY_CORS_ORIGINS'].split(',').map(&:strip)
      puts "CORS allowed origins: #{origins_list.inspect}"

      # Specify the origins that are allowed to access your API.
      # Use '*' to allow any origin (use with caution, generally only for public APIs).
      origins origins_list

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



        puts "Received needhost POST request"

        data = JSON.parse(r.body.read)
        url = data['url']
        # Here you would handle the URL as needed, e.g., log it or send an email
        puts "Received URL: #{url}"


        puts "Ezproxy  ENV dump:\n"
        ENV.select{ |key, value| key =~ /EZPROXY/ }.each do |k,v|
          puts "#{k}=#{v}"
        end


        Mail.defaults do
          # having toruble with the cert - but not
          # sure from the documentation on answers if there actually is a
          # cert to validate against.

          delivery_method :smtp, address: ENV['EZPROXY_EMAIL_RELAY'], port: 25, enable_starttls_auto: false, ssl: false, tls: false
        end



        mail = Mail.deliver do
          from     ENV['EZPROXY_EMAIL_SENDER']
          to       ENV['EZPROXY_EMAIL_TARGETS'].split(',')
          subject  "EZproxy needhost triggered"
          body     "The following URL triggered a needhost request:\n\n#{url}\n"
        end

        puts "Sent email to #{ENV['EZPROXY_EMAIL_TARGETS']}"

        { status: 'success', message: 'URL received' }


      end
    end
  end
end

run App.freeze.app
