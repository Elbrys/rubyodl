#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 7: Show operational state of a particular configuration module"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

module_type = "opendaylight-rest-connector:rest-connector-impl"
module_name = "rest-connector-default-impl"
puts "\nGetting state for module type #{module_type} with name #{module_name}"
sleep(delay)
response = controller.get_module_operational_state(module_type, module_name)
if response.status == NetconfResponseStatus::OK
  puts "\nModule: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 7"