#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

puts "Loading configuration..."
config = YAML.load_file('config.yml')

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
node_id = "openflow:1"

puts "\nGet info about #{node_id} node on the controller"
response = controller.get_node_info(node_id)
if response.status == NetconfResponseStatus::OK
  puts "#{node_id} node info: #{JSON.pretty_generate response.body}"
else
  puts "\nCommand failed: #{response.message}"
  puts "#{response.body.body}" # response.body is response object
end