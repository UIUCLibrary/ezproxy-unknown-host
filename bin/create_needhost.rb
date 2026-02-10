#!/usr/bin/env ruby

require 'erb'



# use the template at  template/needhost.htm.erb
# to create _output/needhost.htm
template_file = File.join(File.dirname(__FILE__), '..', 'template', 'needhost.htm.erb')
output_file = File.join(File.dirname(__FILE__), '..', '_output', 'needhost.htm')

template = ERB.new(File.read(template_file))
File.open(output_file, 'w') do |file|
  file.write(template.result)
end
