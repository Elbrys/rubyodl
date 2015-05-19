#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_2.yml')

puts "\nStarting Demo 10: Add / Delete Node"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

puts "\nShow NETCONF nodes configured on the Controller"
sleep(delay)
response = controller.get_netconf_nodes_in_config
if response.status == NetconfResponseStatus::OK
  puts "Nodes configured: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nCreating new NETCONF node with name #{config['node']['name']}"
node = NetconfNode.new(controller: controller, name: config['node']['name'],
  ip_addr: config['node']['ip_addr'], port_number: config['node']['port_num'],
  admin_name: config['node']['username'], admin_password: config['node']['password'])
puts "#{node.name}: #{JSON.pretty_generate node.to_hash}"

puts "\nAdd #{node.name} NETCONF node to the controller"
sleep(delay)
response = controller.add_netconf_node(node)
if response.status == NetconfResponseStatus::OK
  puts "#{node.name} NETCONF node was successfully added to the controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow NETCONF nodes configured on the Controller"
sleep(delay)
response = controller.get_netconf_nodes_in_config
if response.status == NetconfResponseStatus::OK
  puts "Nodes configured: #{JSON.pretty_generate response.body}"
else
  put "\nDemo terminated: #{response.message}"
  exit
end

puts "\nFind #{node.name} NETCONF node on the controller"
sleep(delay)
response = controller.check_node_config_status(node.name)
if response.status == NetconfResponseStatus::NODE_CONFIGURED
  puts "#{node.name} node is configured"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nShow connection status for all NETCONF nodes"
sleep(delay)
response = controller.get_netconf_nodes_conn_status
if response.status == NetconfResponseStatus::OK
  puts "Nodes connection status:"
  response.body.each do |status_obj|
    puts "#{status_obj[:node]} is #{status_obj[:connected] ? 'connected' : 'not connected'}"
  end
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nShow connection status for the NETCONF node with name #{node.name}"
sleep(delay)
response = controller.check_node_conn_status(node.name)
if [NetconfResponseStatus::NODE_CONNECTED, NetconfResponseStatus::NODE_DISCONNECTED,
    NetconfResponseStatus::NODE_NOT_FOUND].include?(response.status)
  puts "#{node.name} #{response.message}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove NETCONF node with the name #{node.name}"
sleep(delay)
response = controller.delete_netconf_node(node)
if response.status == NetconfResponseStatus::OK
  puts "NETCONF node #{node.name} was successfully removed"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow NETCONF nodes configured on the Controller"
sleep(delay)
response = controller.get_netconf_nodes_in_config
if response.status == NetconfResponseStatus::OK
  puts "Nodes configured: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow connection status for the NETCONF node with name #{node.name}"
sleep(delay)
response = controller.check_node_conn_status(node.name)
if [NetconfResponseStatus::NODE_CONNECTED, NetconfResponseStatus::NODE_DISCONNECTED,
    NetconfResponseStatus::NODE_NOT_FOUND].include?(response.status)
  puts "#{node.name} #{response.message}"
else
  puts "\nDemo terminated: #{response.message}"
end

puts "\nEnd of Demo 10"
