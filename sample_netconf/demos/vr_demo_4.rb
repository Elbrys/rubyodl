#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_4.yml')

puts "\nStarting Demo 4: Get firewall configuration for vRouter"

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

puts "\nShow firewalls configuration of #{vrouter.name}"
sleep(delay)
response = vrouter.get_firewalls_cfg
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} firewalls config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

firewall_group = "FW-ACCEPT-SRC-172_22_17_108"
rules = Rules.new(name: firewall_group)
rule = Rule.new(rule_number: 33, action: "accept",
  source_address: '172.22.17.108')
rules.add_rule(rule)
firewall = Firewall.new(rules: rules)
puts "\nCreate new firewall instance #{firewall_group} on #{vrouter.name}"
sleep(delay)
response = vrouter.create_firewall_instance(firewall)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{firewall_group} was successfully created"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow content of the firewall instance #{firewall_group} on #{vrouter.name}"
sleep(delay)
response = vrouter.get_firewall_instance_cfg(firewall_group)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{firewall_group}: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow firewalls configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_firewalls_cfg
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} firewalls config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove firewall instance #{firewall_group} from #{vrouter.name}"
sleep(delay)
response = vrouter.delete_firewall_instance(firewall)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{firewall_group} was successfully deleted"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow firewalls configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_firewalls_cfg
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} firewalls config: #{JSON.pretty_generate response.body}"
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

puts "\nEnd of demo 4"