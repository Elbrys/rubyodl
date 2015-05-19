#!/usr/bin/env ruby

require 'rubybvc'
require 'yaml'

delay = 5

puts "Loading configuration..."
config = YAML.load_file("config.yml")

puts "\nStarting Demo 3: Get detailed about ports"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
puts "Controller: #{JSON.pretty_generate controller.to_hash}"

name = config['node']['name']
puts "\nGet information for ports on OpenFlowNode: #{name}"
sleep(delay)
of_switch = OFSwitch.new(controller: controller, name: name)
response = of_switch.get_ports_list
if response.status == NetconfResponseStatus::OK
  ports = response.body
  ports.each do |port|
    response = of_switch.get_port_detail_info(port)
    if response.status == NetconfResponseStatus::OK
      puts "\nPort #{port} info: #{JSON.pretty_generate response.body}"
    else
      puts "\nDemo terminated #{response.message}"
      exit
    end
  end
else
  puts "\nDemo terminated: #{response.message}"
  exit
end

puts "\nEnd of demo 3"