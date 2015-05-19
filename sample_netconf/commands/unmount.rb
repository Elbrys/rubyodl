#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'

puts "Loading configuration..."
config = YAML.load_file('config.yml')

controller = Controller.new(ip_addr: config['controller']['ip_addr'],
  admin_name: config['controller']['username'],
  admin_password: config['controller']['password'])
node = NetconfNode.new(controller: controller, name: config['node']['name'],
  ip_addr: config['node']['ip_addr'], port_number: config['node']['port_num'],
  admin_name: config['node']['username'],
  admin_password: config['node']['password'])

puts "\nRemoving #{node.name} from the controller #{controller.ip}"
response = controller.delete_netconf_node(node)
if response.status == NetconfResponseStatus::OK
  puts "#{node.name} was successfully removed from the controller"
else
  puts "\nCommand failed: #{response.message}"
end
