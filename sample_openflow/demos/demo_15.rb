#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 15: Setting OpenFlow flow on the Controller:"\
  "push to a ethernet type VLAN traffic on a particular VLAN ID and port"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
eth_type = 2048
vlan_id = 100
input_port = 3
# Ethernet type 33024(0x8100) -> VLAN tagged frame (Customer VLAN Tag Type)
# Ethernet type 34984(0x88A8) -> QINQ VLAN tagged frame (Service VLAN tag identifier)
push_eth_type = 34984
push_vlan_id = 200
output_port = 5

flow_id = 22
table_id = 0
flow_entry = FlowEntry.new(flow_table_id: table_id, flow_id: flow_id,
  name: 'push_vlan_100_flow', flow_priority: 1013, cookie: 407,
  cookie_mask: 255, hard_timeout: 3400, idle_timeout: 3400)
# Instruction: 'Apply-action'
#     Actions: 'PushVlan'
#              'Set Field'
#              'Output
instruction = Instruction.new(instruction_order: 0)
push_action = PushVlanHeaderAction.new(order: 0, eth_type: push_eth_type)
instruction.add_apply_action(push_action)
set_action = SetFieldAction.new(order: 1, vlan_id: push_vlan_id)
instruction.add_apply_action(set_action)
out_action = OutputAction.new(order: 2, port: output_port)
instruction.add_apply_action(out_action)
flow_entry.add_instruction(instruction)

# Match Fields: Ethernet Type
#               VLAN ID
#               Input Port
match = Match.new(eth_type: eth_type, vlan_id: vlan_id, in_port: input_port)
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

puts "\nEnd of Demo 15"