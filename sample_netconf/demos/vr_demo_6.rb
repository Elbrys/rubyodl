#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_4.yml')

puts "\nStarting Demo 6: Get information on loopback interfaces configured on"\
  "vRouter"

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
vrouter = VRouter5600.new(controller: controller, name: config['node']['name'],
  ip_addr: config['node']['ip_addr'], port_number: config['node']['port_num'],
  admin_name: config['node']['username'],
  admin_password: config['node']['password'])
puts "Controller: #{controller.ip}, #{vrouter.name}: #{vrouter.ip}"

puts "\nAdd #{vrouter.name} to controller"
sleep(delay)
response = controller.add_netconf_node(vrouter)
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} added to the controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nCheck #{vrouter.name} connection status"
sleep(delay)
response = controller.check_node_conn_status(vrouter.name)
if response.status == NetconfResponseStatus::NODE_CONNECTED
  puts "#{vrouter.name} is connected to the Controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow list of loopback interfaces on #{vrouter.name}"
sleep(delay)
response = vrouter.get_loopback_interfaces_list
if response.status == NetconfResponseStatus::OK
  puts "Loopback interfaces: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

interface_name = "lo4"
puts "\nShow #{interface_name} loopback interface configuration on "\
  "#{vrouter.name}"
sleep(delay)
response = vrouter.get_loopback_interface_cfg(interface_name)
if response.status == NetconfResponseStatus::OK
  puts "Loopback interface #{interface_name} config: "\
    "#{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow configuration of loopback interfaces on #{vrouter.name}"
sleep(delay)
response = vrouter.get_loopback_interfaces_cfg
if response.status == NetconfResponseStatus::OK
  puts "Loopback interfaces config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow interfaces configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_interfaces_cfg
if response.status == NetconfResponseStatus::OK
  puts "Interfaces config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove #{vrouter.name} NETCONF node from controller"
sleep(delay)
response = controller.delete_netconf_node(vrouter)
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} was successfully removed from the controller"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of demo 6"