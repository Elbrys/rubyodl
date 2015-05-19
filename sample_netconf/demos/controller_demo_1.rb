#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 1: List of YANG models supported by the Controller"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nGetting list of models"
sleep(delay)
node_name = "controller-config"
response = controller.get_schemas(node_name)
if response.status == NetconfResponseStatus::OK
  puts "\nYANG models list: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 1"