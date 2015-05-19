#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 1000: Getting all information about an OpenFlow Node"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
puts "\nGet switch information"
sleep(delay)
response = of_switch.get_switch_info
if response.status == NetconfResponseStatus::OK
  puts "#{name} info: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_features_info
if response.status == NetconfResponseStatus::OK
  puts "\n#{name} features: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_ports_brief_info
if response.status == NetconfResponseStatus::OK
  puts "\n#{name} ports: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

port_num = 1
response = of_switch.get_port_detail_info(port_num)
if response.status == NetconfResponseStatus::OK
  puts "\nPort #{port_num} info: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

table_id = 0
response = of_switch.get_operational_flows(table_id: table_id)
if response.status == NetconfResponseStatus::OK
  puts "\nTable #{table_id} operational flows: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_operational_flows_ovs_syntax(table_id: table_id, sort: true)
if response.status == NetconfResponseStatus::OK
  puts "\nTable #{table_id} operational flows: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_configured_flows(table_id: table_id)
if response.status == NetconfResponseStatus::OK
  puts "\nTable #{table_id} configured flows: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_configured_flows_ovs_syntax(table_id: table_id, sort: true)
if response.status == NetconfResponseStatus::OK
  puts "\nTable #{table_id} configured flows: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nEnd of demo 1000"