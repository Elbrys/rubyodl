#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 5: List of all NETCONF operations supported by the Controller"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nGetting list of operations"
sleep(delay)
response = controller.get_netconf_operations("controller-config")
if response.status == NetconfResponseStatus::OK
  puts "\nNETCONF operations: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "End of Demo 5"