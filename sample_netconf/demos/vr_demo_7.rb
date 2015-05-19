#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config_4.yml')

puts "\nStarting Demo 7: Create complex firewalls for vRouter"

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

puts "\nShow firewalls configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_firewalls_cfg
if response.status == NetconfResponseStatus::OK
  puts "#{vrouter.name} firewalls config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

fw_name_1 = "ACCEPT-SRC-IPADDR"
puts "\nCreate new firewall instance #{fw_name_1} on #{vrouter.name}"
sleep(delay)
rules = Rules.new(name: fw_name_1)
rule = Rule.new(rule_number: 30, action: "accept",
  source_address: "172.22.17.107")
rules.add_rule(rule)
firewall1 = Firewall.new(rules: rules)
response = vrouter.create_firewall_instance(firewall1)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{fw_name_1} was successfully created"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

fw_name_2 = "DROP-ICMP"
puts "\nCreate new firewall instance #{fw_name_2} on #{vrouter.name}"
sleep(delay)
rules = Rules.new(name: fw_name_2)
rule = Rule.new(rule_number: 40, action: "drop", icmp_typename: "ping")
rules.add_rule(rule)
firewall2 = Firewall.new(rules: rules)
response = vrouter.create_firewall_instance(firewall2)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{fw_name_2} was successfully created"
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

interface_name = "dp0p1p7"
puts "\nApply firewall #{fw_name_1} to inbound traffic and #{fw_name_2} to "\
  "outbound traffic on the #{interface_name} dataplane interface"
sleep(delay)
response = vrouter.set_dataplane_interface_firewall(interface_name,
  inbound_firewall_name: fw_name_1, outbound_firewall_name: fw_name_2)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instances were successfully applied to the #{interface_name} "\
    "dataplane interface"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow #{interface_name} dataplane interface configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_dataplane_interface_cfg(interface_name)
if response.status == NetconfResponseStatus::OK
  puts "Interface #{interface_name} config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove firewall settings for #{vrouter.name} dataplane interface"
sleep(delay)
response = vrouter.delete_dataplane_interface_firewall(interface_name)
if response.status == NetconfResponseStatus::OK
  puts "Firewall settings successfully removed from #{interface_name} dataplane "\
    "interface"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nShow #{interface_name} dataplane interface configuration on #{vrouter.name}"
sleep(delay)
response = vrouter.get_dataplane_interface_cfg(interface_name)
if response.status == NetconfResponseStatus::OK
  puts "Interface #{interface_name} config: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove firewall instance #{fw_name_1} from #{vrouter.name}"
sleep(delay)
response = vrouter.delete_firewall_instance(firewall1)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{firewall1.rules.name} was successfully deleted"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nRemove firewall instance #{fw_name_2} from #{vrouter.name}"
sleep(delay)
response = vrouter.delete_firewall_instance(firewall2)
if response.status == NetconfResponseStatus::OK
  puts "Firewall instance #{firewall2.rules.name} was successfully deleted"
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

puts "\nEnd of demo 7"