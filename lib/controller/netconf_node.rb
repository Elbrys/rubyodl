class NetconfNode
  attr_reader :name
  attr_reader :ip
  attr_reader :port
  attr_reader :username
  attr_reader :password
  attr_reader :tcp_only
  
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
end