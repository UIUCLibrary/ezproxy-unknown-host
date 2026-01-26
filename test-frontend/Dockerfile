FROM httpd:2.4

# TOD: make multi-stage to generate needhost.htm file,
# then get rid of all the ruby stuff
# For now using static files.

COPY ./www/ /usr/local/apache2/htdocs/


# Set EZPROXY_CORS_ORIGINS in the docker-compose.yml or env file

# EXAMPLE:
