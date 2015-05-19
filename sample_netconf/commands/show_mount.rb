#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

puts "Loading configuration..."
config = YAML.load_file('config.yml')

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])

puts "\nNETCONF nodes configured on the Controller"
response = controller.get_all_nodes_in_config
if response.status == NetconfResponseStatus::OK
  puts "Nodes configured: #{JSON.pretty_generate response.body}"
else
  puts "\nCommand failed: #{response.message}"
  exit
end

puts "\nNETCONF nodes connection status on the Controller"
response = controller.get_all_nodes_conn_status
if response.status == NetconfResponseStatus::OK
  puts "Nodes connection status:"
  response.body.each do |status_obj|
    puts "\t#{status_obj[:node]} is #{status_obj[:connected] ? 'connected' : 'not connected'}"
  end
else
  puts "\nCommand failed: #{response.message}"
  puts "#{response.body.body}" # response.body is response object
end