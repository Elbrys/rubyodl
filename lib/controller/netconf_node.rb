require 'controller/node'
class NetconfNode < Node
  attr_reader :ip, :port, :username, :password, :tcp_only
  
  def initialize(controller: nil, name: nil, ip_addr: nil,
      port_number: nil, admin_name: nil, admin_password: nil,
      tcp_only: false)
    super(controller: controller, name: name)
    raise ArgumentError, "IP Address (ip_addr) required" unless ip_addr
    raise ArgumentError, "Port Number (port_number) required" unless port_number
    raise ArgumentError, "Admin Username (admin_name) required" unless admin_name
    raise ArgumentError, "Admin Password (admin_password) required" unless admin_password
    
    @ip = ip_addr
    @port = port_number
    @username = admin_name
    @password = admin_password
    @tcp_only = tcp_only
  end
  
  def to_hash
    {:controller => @controller.to_hash, :name => @name, :ip_addr => @ip,
      :port_num => @port, :admin_name => @username, :admin_password => @password}
  end
end