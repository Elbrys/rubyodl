#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 6: Show operational state of all configuration modules on the Controller"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nGetting operational states"
sleep(delay)
response = controller.get_all_modules_operational_state
if response.status == NetconfResponseStatus::OK
  puts "\nModules: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 6"