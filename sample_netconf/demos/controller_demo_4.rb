#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 4: Retrieve specific service provider info"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = "opendaylight-md-sal-binding:binding-data-broker"
puts "\nRetrieving info for #{name}"
sleep(delay)
response = controller.get_service_provider_info(name)
if response.status == NetconfResponseStatus::OK
  puts "\nService provider: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 4"