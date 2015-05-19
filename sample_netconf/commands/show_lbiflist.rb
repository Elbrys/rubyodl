#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

puts "Loading configuration..."
config = YAML.load_file('config.yml')

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
vrouter = VRouter5600.new(controller: controller, name: config['node']['name'],
  ip_addr: config['node']['ip_addr'], port_number: config['node']['port_num'],
  admin_name: config['node']['username'],
  admin_password: config['node']['password'])
puts "Controller: #{controller.ip}, #{vrouter.name}: #{vrouter.ip}"

response = vrouter.get_loopback_interfaces_list
if response.status == NetconfResponseStatus::OK
  puts "Loopback interfaces: #{JSON.pretty_generate response.body}"
else
  puts "\nCommand failed: #{response.message}"
  puts "#{response.body.body}" # response.body is response object
end