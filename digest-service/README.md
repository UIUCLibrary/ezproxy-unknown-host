# Digest Service

The ruby code for now is geared towards the UIUC environment, which has an internal smtp server for sending mail. 


# Environmental Variables

  * EZPROXY_ALERT_EMAIL_TARGETS - comma separated list of email addresses for sending alerts
  * EZPROXY_EMAIL_RELAY         - smtp target
  * EZPROXY_EMAIL_SENDER        - the email for the "from" address
  * RUBY_IMAGE_TAG              - Ruby version to base docker image off of, 
                                  used to keep ruby version consistent for now
                                  between containers in the project


