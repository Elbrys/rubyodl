#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 2: Get more detailed information for a particular OpenFlow Node"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
puts "\nGet information about Openflow node #{name}"
sleep(delay)
of_switch = OFSwitch.new(controller: controller, name: name)
response = of_switch.get_switch_info
if response.status == NetconfResponseStatus::OK
  puts "Node #{name} generic information: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_features_info
if response.status == NetconfResponseStatus::OK
  puts "Node #{name} features: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_ports_list
if response.status == NetconfResponseStatus::OK
  puts "Node #{name} ports list: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

response = of_switch.get_ports_brief_info
if response.status == NetconfResponseStatus::OK
  puts "Nodes #{name} ports brief information: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nEnd of demo 2"