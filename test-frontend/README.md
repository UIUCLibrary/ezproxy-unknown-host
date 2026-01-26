Ok, so to make some black box testing easier we'll run a simple web server, with content from ../output copied to /var/www/html and a configuration that will respond to port 80, with the slight tweak of using mod_substitute to change '^U' and '^V' to the query strings or some sort of placeholder.

