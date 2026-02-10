# ezproxy-unknown-host

A template and web service that will redirect users to an unknown host, while notifying the electronic resoure librarians of an issue.

# How does this work?

When a user tries to use a url that EzProxy has no configuration for, EzProxy will look for a template at docs/needhost.htm.

Javascript in our needhost.html file takes the passed in url `^V` and set the browser to load that location at the end of the "timeout" in milliseconds.

```
setTimeout("window.location.href='^V'", 5000);
```


# Simple approach

If you don't care about being notified when users are shown this message, you can probalby just manually modify the file in `simple_page/needhost.htm` to include any styling you like and move it to your server's `ezproxy/docs folder`.

# Full install

Note - the docker-compose.yml file and docker compose on the top-level of this project are intended for testing. For actual deployment, you'll want to create the needhost.htm file, place it in the ezproxy/docs folder on your ezprxoy server, and run the email-service container. see below for full details.

## Set up needhost.htm file

### Set ENV variables

Making the code a bit more flexible here so we can pretty easily create a template for testing and production.

  * *BEACON_BASE_URL* - Base url (protocol://fully-qualified-domain-name.edu). The endpoint will be appended to this.


## Run the bin/create_

`bin/create_needhost.rb`

# Installing the needhost.htm

The needhost.htm file will need to be copied into your EzProxy docs folder. This will be at the same level as the ezproxy binary/executable.

More information can be found at https://help.oclc.org/Library_Management/EZproxy/Manage_EZproxy/Default_web_pages


## Set up email service


# Testing

See the steps above about creating the _output/needhost.htm file. (At some point we probably could load a docker image just to create that file)

# To-Dos

## Replace ^U and ^V in test stack

I couldn't figure out a way in apache 2.4 to use a server variable or environmental variable with mod_subsitute to perform a similar role, so ended up just using a static html file.

Did figure out following would `SetEnvIf Query_String (^|&)url=([^&]*) EZPROXY_TARGET_URL=$2` set a variable.
