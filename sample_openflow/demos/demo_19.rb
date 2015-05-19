#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 19: Setting OpenFlow flow on the Controller: "\
  "send to controller traffic with a particular ipv6 source and destination, "\
  "IPv6 Flow Label, IP DSCP, and TCP source and destination ports"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
eth_type = 34525
ipv6_src = "4321::3210:3210:3210:3210/80"
ipv6_dst = "1234:1234:1234:1234::5678:5678/64"
ipv6_flabel = 33
ip_dscp = 60
ip_proto = 6
tcp_src_port = 11111
tcp_dst_port = 22222

output_port = "CONTROLLER"

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, IPv6 Source #{ipv6_src}, "\
  "IPv6 Destination #{ipv6_dst}, IPv6 Flow Label #{ipv6_flabel}, "\
  "IP DSCP #{ip_dscp}, TCP Source Port #{tcp_src_port}, "\
  "TCP Destination Port #{tcp_dst_port}"
puts "Action: Output (controller)"

sleep(delay)
flow_id = 26
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1017, flow_table_id: table_id,
  flow_id: flow_id, name: "demo19", cookie: 23, hard_timeout: 1200,
  idle_timeout: 3400)
# Instruction: 'Apply-action'
#     Actions: 'Output'
instruction = Instruction.new(instruction_order: 0)
action = OutputAction.new(order: 0, port: output_port)
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match Fields: Ethernet Type
#               IPv6 Source Addres
#               IPv6 Destination Address
#               IPv6 Flow Label
#               IP protocol number (TCP)
#               IP DCSP
#               TCP Source Port
#               TCP Destination Port
match = Match.new(eth_type: eth_type, ipv6_source: ipv6_src,
  ipv6_destination: ipv6_dst, ip_protocol_num: ip_proto, ip_dscp: ip_dscp,
  tcp_source_port: tcp_src_port, tcp_destination_port: tcp_dst_port,
  ipv6_flabel: ipv6_flabel)
flow_entry.add_match(match)

puts"\nFlow to send: #{JSON.pretty_generate flow_entry.to_hash}"

sleep(delay)
response = of_switch.add_modify_flow(flow_entry)
if response.status == NetconfResponseStatus::OK
  puts "\nFlow successfully added to the controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\n Get configured flow from the Controller"
response = of_switch.get_configured_flow(table_id: table_id, flow_id: flow_id)
if response.status == NetconfResponseStatus::OK
  puts "Flow successfully read from the controller"
  puts "Flow info: #{JSON.pretty_generate response.body}"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nDelete flow with ID #{flow_id} from Controller's cache and from table "\
  "#{table_id} on #{name} node"
sleep(delay)
response = of_switch.delete_flow(flow_id: flow_id, table_id: table_id)
if response.status == NetconfResponseStatus::OK
  puts "Flow successfully removed from the controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nEnd of Demo 19"
