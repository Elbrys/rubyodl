#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_1.yml')

puts "\nStarting Demo 2: Retrieve specific YANG model definition from the Controller"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr:config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

yang_model_name = "flow-topology-discovery"
yang_model_version = "2013-08-19"
puts "\nRetrieving model #{yang_model_name}"
node_name = "controller-config"
response = controller.get_schema(node_name, id: yang_model_name,
  version: yang_model_version)
if response.status == NetconfResponseStatus::OK
  puts "\nYANG model: #{response.body}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 2"