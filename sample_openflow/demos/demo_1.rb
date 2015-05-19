#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 1: Get information for OpenFlow nodes"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nGet list of OpenFlow nodes connected to controller"
sleep(delay)
response = controller.get_openflow_nodes_operational_list
if response.status == NetconfResponseStatus::OK
  puts 'OpenFlow node names (composed as "openflow:datapathid"):'
  puts "#{JSON.pretty_generate response.body}"
  node_names = response.body
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nGet generic information about OpenFlow nodes"
sleep(delay)
node_names.each do |name|
of_switch = OFSwitch.new(controller: controller, name: name)
  response = of_switch.get_switch_info
  if response.status == NetconfResponseStatus::OK
    puts "#{name} info: #{JSON.pretty_generate response.body}"
  else
    puts "\nDemo terminated: #{response.message}"
    exit
  end
end

puts "\nEnd of Demo 1"