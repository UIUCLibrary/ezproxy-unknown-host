require 'roda'
require 'rack/cors'
require 'json'

require 'mail'

class App < Roda
  plugin :json

  origins_list = ENV['EZPROXY_CORS_ORIGINS'].split(',').map(&:strip)


  use Rack::Cors do
    allow do

      puts "CORS allowed o
      rigins: #{origins_list.inspect}"

      # Specify the origins that are allowed to access your API.
      # Use '*' to allow any origin (use with caution, generally only for public APIs).
      origins origins_list
      # origins do |source_origin, env|
     #   if origins_list.include?(source_origin)
     #     puts "CORS origin allowed: #{source_origin}"
     #     trueq
     #   else
     #     puts "CORS origin denied: #{source_origin}"
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


        puts "Origins list: #{origins_list.inspect}"

        puts "Received needhost POST request"

        puts "Request headers: #{r.env.select { |k, v| k.start_with?('HTTP_') }.inspect}"
        puts "Request body: #{r.body.read}"

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
