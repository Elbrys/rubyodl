class NetconfNode
  attr_reader :name, :ip, :port, :username, :password, :tcp_only
  
  def initialize(controller: nil, node_name: nil, ip_addr: nil,
      port_number: nil, admin_name: nil, admin_password: nil,
      tcp_only: false)
    @controller = controller
    @name = node_name
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