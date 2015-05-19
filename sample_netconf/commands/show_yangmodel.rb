#! /usr/bin/env ruby

require 'rubybvc'
require 'yaml'
require 'optparse'

options = {:identifier => nil, :version => nil}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: show_yangmodel.rb [options]"
  opts.on('-i', '--identifier id', 'Identifier') do |id|
    options[:identifier] = id
  end
  
  opts.on('-v', '--version version', "Version") do |version|
    options[:version] = version
  end
  
  opts.on('-h', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:identifier].nil?
  print 'Enter identifier: '
  options[:identifier] = gets.chomp
end

if options[:version].nil?
  print 'Enter version: '
  options[:version] = gets.chomp
end

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

puts "\nGet schema for #{options}"
response = vrouter.get_schema(id: options[:identifier],
  version: options[:versions])
if response.status == NetconfResponseStatus::OK
  puts "\nYANG model definition: #{response.body}"
else
  puts "\nCommand failed: #{response.message}"
  puts "#{response.body.body}" # response.body is response object
end
