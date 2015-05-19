#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 22: Setting OpenFlow flow on the Controller: "\
  "send to a physical port traffic with a particular IPv4 destination and in "\
  "port"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
eth_type = 2048
in_port = 13
ipv4_dst = "10.12.5.4/32"

push_ether_type = 34887
mpls_label = 27
output_port = 14

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, IPv4 destination "\
  "#{ipv4_dst}, In port #{in_port}"
puts "Action: Push MPLS Header (Ethernet Type 0x#{push_ether_type.to_s(16)}, "\
  "Set Field (MPLS Label #{mpls_label}, "\
  "Output (Physical Port Number #{output_port})"

sleep(delay)
flow_id = 28
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1021, flow_table_id: table_id,
  flow_id: flow_id, name: "Push MPLS Label", cookie: 654, cookie_mask: 255)
# Instruction: 'Apply-action'
#     Actions: 'Push MPLS Header'
#              'Set Field'
#              'Output'
instruction = Instruction.new(instruction_order: 0)
action = PushMplsHeaderAction.new(order: 0, eth_type: push_ether_type)
instruction.add_apply_action(action)
action = SetFieldAction.new(order: 1, mpls_label: mpls_label)
instruction.add_apply_action(action)
action = OutputAction.new(order: 2, port: output_port)
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match Fields: Ethernet Type
#               IPv4 Destination Address
#               Input Port
match = Match.new(eth_type: eth_type, ipv4_destination: ipv4_dst,
  in_port: in_port)
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

puts "\nEnd of Demo 22"
