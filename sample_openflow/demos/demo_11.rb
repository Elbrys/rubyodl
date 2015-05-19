#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file('config.yml')

puts "\nStarting Demo 11: Setting OpenFlow flow on the Controller: "\
  "foward normal traffic with particular ethernet source and destination "\
  "addresses, specific IPv4 source and destination addresses, ICMPv4 type, "\
  "and ICMPv4 code, coming in on a particular port following a particular IP "\
  "protocol, DSCP and ECN"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
of_switch = OFSwitch.new(controller: controller, name: name)
# Ethernet type MUST be 2048 (0x800) -> IPv4 protocol
# IP Protocol type MUST be 1 -> ICMP
eth_type = 2048
eth_src = "00:00:00:11:23:ae"
eth_dst = "00:ff:20:01:1a:3d"
ipv4_src = "17.1.2.3/8"
ipv4_dst = "172.168.5.6/18"
ip_proto = 1
ip_dscp = 27
ip_ecn = 3
icmpv4_type = 6 # Alternative Host Address
icmpv4_code = 3 # Alternative address for host
input_port = 10

puts "\nMatch: Ethernet Type 0x#{eth_type.to_s(16)}, Ethernet source #{eth_src}"\
  ", Ethernet destination #{eth_dst}, IPv4 source #{ipv4_src}, "\
  "IPv4 destination #{ipv4_dst}, IP Protocol Number #{ip_proto}, "\
  "IP DSCP #{ip_dscp}, IP ECN #{ip_ecn}, ICMPv4 Type #{icmpv4_type}, "\
  "ICMPv4 Code #{icmpv4_code}, Input Port #{input_port}"
puts "Action: Output (normal)"

sleep(delay)

flow_id = 19
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1009, flow_id: flow_id,
  flow_table_id: table_id)
# Instruction: 'Apply-action'
#      Action: 'Drop'
instruction = Instruction.new(instruction_order: 0)
action = OutputAction.new(order: 0, port: "NORMAL")
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match fields: Ethernet type
#               Ethernet Source Address
#               Ethernet Destination Address
#               IPv4 Source Address
#               IPv4 Destination Address
#               IP Protocol Number
#               IP DSCP
#               IP ECN
#               ICMPv4 Type
#               ICMPv4 Code
#               Input port
match = Match.new(eth_type: eth_type, ethernet_source: eth_src,
  ethernet_destination: eth_dst, ipv4_destination: ipv4_dst,
  ipv4_source: ipv4_src, ip_protocol_num: ip_proto, ip_dscp: ip_dscp,
  ip_ecn: ip_ecn, icmpv4_type: icmpv4_type, icmpv4_code: icmpv4_code,
  in_port: input_port)
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

puts "\nEnd of demo 11"