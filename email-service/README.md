


# Email Service


Setting up a roda web api that can be called by javascript to trigge an eamil to the electronic resources ilbrarians. Thsese calls will be made by client-side javascript at the moment.

# Environmental Variables

  * EZPROXY_ALERT_EMAIL_TARGET
  * EZPROXY_EMAIL_RELAY

  # Endpoint

    * `needhost-triggered?url=<the_triggering_url_encoded>`
      The `the_triggering_url_encoded` shoudl be encoded via encodedUrLParam in javascript. Requests without this parameter will be silently dropped


      