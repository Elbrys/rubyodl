#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 5: Setting OpenFlow flow on the Controller:"\
  "drop ethernet traffic with specific ipv4 source"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
# Ethernet type MUST be 2048 (0x800) -> IPv4 protocol
eth_type = 2048
ipv4_src = "10.11.12.13/24"

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, IPv4 source #{ipv4_src}"
puts "Action: Drop"

sleep(delay)

flow_id = 12
table_id = 0
flow_entry = FlowEntry.new(flow_table_id: table_id, flow_id: flow_id,
  flow_priority: 1003)
# Instruction: 'Appy-action'
#      Action: 'Drop'
instruction = Instruction.new(instruction_order: 0)
action = DropAction.new(order: 0)
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match fields: Ethernet Type,
#               IPv4 Source Address
match = Match.new(eth_type: eth_type, ipv4_source: ipv4_src)
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

puts "\nEnd of Demo 5"