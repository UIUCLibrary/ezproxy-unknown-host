# Event Listener Service

This is a docker container that will run a ruby Roda server with a simple api. At some point we may need to tweak this to have more counter measures against bots.


# Environmental Variables

  * EZPROXY_ALERT_EMAIL_TARGETS - comma separated list of email addresses for sending alerts
  * EZPROXY_EMAIL_RELAY         - smtp target
  * EZPROXY_EMAIL_SENDER        - the email for the "from" address
  * EZPROXY_CORS_ORIGINS        - your ezproxy base urls, see section below
  * RUBY_IMAGE_TAG              - Ruby version to base docker image off of, 
                                  used to keep ruby versiosn consistent for now
                                  between containers in the project


## EZPROXY_CORS_ORIGINS example

This should be a comma separated list of the base urls ezproxy servers.

```
EZPROXY_CORS_ORIGINS="https://ezproxy_1.library.foo.edu,https://ezproxy_2.library.foo.edu"
```

For more information, read the [MDN Cross-Origin Resource Sharing (CORS) article](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)
                                  

  # Endpoint

    * a POST to `needhost' with a json in the body 
      ```
      {"url":"the_attempted_url"}
      ```
      
See the [template/needhost.htm.erb](template/needhost.htm.erb template) to see a javascript call that calls this endpoint.

# Testing 

## Local testing....

Probably easiest to use docker containers w/ curl

  1. `docker compose build`
  1. `docker compose up -d`
  1. `curl -X POST 'http://localhost:4000/needhost' -H 'Content-Type: application/json' -d '{"url":"https://testing.library.illinois.edu/2026_03_24_02"}'`

  Note - depending on your `EZPROXY_CORS_ORIGINS` in your `.env` file, you may need to pass in -H "Origin: http://<some-origin>" to avoid some warnings and errors.  If you have `EZPROXY_CORS_ORIGINS="http://localhost:4000` it should work.


### Did it record?

  1. `docker compose exec -it database bash`
  1. `psql -U ezproxy events`
  1. `select * from events`



      

      