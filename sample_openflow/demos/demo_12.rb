#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 12: Setting OpenFlow flow on the Controller: "\
  "send to controller traffic with particular ethernet source and destination "\
  "addresses, specific ARP operation, source and target IPv4 addresses and "\
  "source and target addresses"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
# Ethernet type MUST be 2054 (0x806) -> ARP protocol
eth_type = 2054
eth_src = "11:ab:fe:01:03:31"
eth_dst = "ff:ff:ff:ff:ff:ff"
arp_opcode = 1 # ARP Request
arp_src_ipv4_addr = "192.168.4.1"
arp_tgt_ipv4_addr = "10.21.22.23"
arp_src_hw_addr = "12:34:56:78:98:ab"
arp_tgt_hw_addr = "fe:dc:ba:98:76:54"

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, Ethernet source #{eth_src},"\
  "Ethernet destination #{eth_dst}, ARP Operation #{arp_opcode},"\
  "ARP source IPv4 #{arp_src_ipv4_addr}, ARP target IPv4 #{arp_tgt_ipv4_addr}"\
  "ARP source hardware address #{arp_src_hw_addr},"\
  "ARP target hardware address #{arp_tgt_hw_addr}"
puts "Action: Output (controller)"

sleep(delay)

flow_id = 19
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1010, flow_table_id: table_id,
  flow_id: flow_id)

# Instruction: 'Apply-action'
#      Action: 'Output' CONTROLLER
instruction = Instruction.new(instruction_order: 0)
action = OutputAction.new(order: 0, port: "CONTROLLER")
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match fields: Ethernet Type
#               Ethernet Source Address
#               Ethernet Destination Address
#               ARP Operation
#               ARP Source IPv4 address
#               ARP Target IPv4 address
#               ARP Source Hardware Address
#               ARP Target Hardware Address
match = Match.new(eth_type: eth_type, ethernet_source: eth_src,
  ethernet_destination: eth_dst, arp_op_code: arp_opcode,
  arp_source_ipv4: arp_src_ipv4_addr, arp_target_ipv4: arp_tgt_ipv4_addr,
  arp_source_hardware_address: arp_src_hw_addr,
  arp_target_hardware_address: arp_tgt_hw_addr)
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

puts "\nEnd of demo 12"
