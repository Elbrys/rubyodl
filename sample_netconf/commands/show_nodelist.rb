#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

puts "Loading configuration..."
config = YAML.load_file('config.yml')

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])

puts "\nGet list of all nodes registered on the Controller"
response = controller.get_nodes_operational_list
if response.status == NetconfResponseStatus::OK
  puts "Nodes: #{JSON.pretty_generate response.body}"
else
  puts "\nCommand failed: #{response.message}"
  puts "#{response.body.body}" # response.body is response object
end