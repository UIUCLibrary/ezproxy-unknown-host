# Email Service

This is a docker container that will run a ruby Roda server with a simple api. At some point we may need to tweak this to have more counter measures against bots.

The docker compose file is geared towards testing. I'd recommend using a docker file with just the "email-service", with whatever tweaks you need for your environment.

The ruby code for now is geared towards the UIUC environment, which has an internal smtp server for sending mail.

# Environmental Variables

  * EZPROXY_ALERT_EMAIL_TARGETS - comma separated list of email addresses for sending alerts
  * EZPROXY_EMAIL_RELAY         - smtp target
  * EZPROXY_EMAIL_SENDER        - the email for the "from" address
  * EZPROXY_CORS_ORIGINS        - your ezproxy base urls, see section below


## EZPROXY_CORS_ORIGINS example

This should be a comma separated list of the base urls ezproxy servers.

```
EZPROXY_CORS_ORIGINS="https://ezproxy_1.library.foo.edu,https://ezproxy_2.library.foo.edu"
```

For more information, read the [MDN Cross-Origin Resource Sharing (CORS) article](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)
                                  

  # Endpoint

    * a POST to `needhost' with a json in the body 
      ```
      url=the_attempted_url
      ```
      
See the [template/needhost.htm.erb](template/needhost.htm.erb template) to see a javascript call that calls this endpoint.
      

      