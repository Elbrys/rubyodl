#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 7: Setting OpenFlow flow on the Controller: "\
  "send to controller traffic with particular ethernet source and destination "\
  "addresses as well as specific ipv4 source and destination addresses coming "\
  "in on a particular port"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
# Ethernet type MUST be 2048 (0x800) -> IPv4 protocol
eth_type = 2048
eth_src = "00:1a:1b:00:22:aa"
eth_dst = "00:2b:00:60:ff:f1"
ipv4_src = "44.44.44.1/24"
ipv4_dst = "55.55.55.1/16"
input_port = 13

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, Ethernet source #{eth_src}"\
  ", Ethernet destination #{eth_dst}, IPv4 source #{ipv4_src}, "\
  "IPv4 destination #{ipv4_dst}, Input Port #{input_port}"
puts "Action: Output (controller)"

sleep(delay)

flow_id = 15
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1005, flow_id: flow_id, flow_table_id: table_id)
# Instruction: 'Apply-action'
#      Action: 'Drop'
instruction = Instruction.new(instruction_order: 0)
action = OutputAction.new(order: 0, port: "CONTROLLER", max_length: 60)
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match fields: Ethernet type
#               Ethernet Source Address
#               Ethernet Destination Address
#               IPv4 Source Address
#               IPv4 Destination Address
#               Input port
match = Match.new(eth_type: eth_type, ethernet_source: eth_src,
  ethernet_destination: eth_dst, ipv4_destination: ipv4_dst,
  ipv4_source: ipv4_src, in_port: input_port)
flow_entry.add_match(match)

puts "\nFlow to send: #{JSON.pretty_generate flow_entry.to_hash}"

sleep(delay)
response = of_switch.add_modify_flow(flow_entry)
if response.status == NetconfResponseStatus::OK
  puts "Flow successfully added to the Controller"
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nGet configured flow from the Controller"
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

puts "\nEnd of demo 7"