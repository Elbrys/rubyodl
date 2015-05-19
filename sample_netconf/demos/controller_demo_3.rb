#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 3: List of service provide applications on the controller"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nGetting providers"
sleep(delay)
response = controller.get_service_providers_info
if response.status == NetconfResponseStatus::OK
  puts "Service providers: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 3"