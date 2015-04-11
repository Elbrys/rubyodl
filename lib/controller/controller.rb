class Controller
  require 'json'
  require 'utils/rest_agent'
  require 'utils/netconf_response'
  
  attr_reader :ip
  attr_reader :port
  attr_reader :username
  attr_reader :password
  attr_reader :timeout
  
  def initialize(ip_addr: nil, port_number: 8181, admin_name: nil, admin_password: nil, timeout_in_s: 5)
    @ip = ip_addr
    @port = port_number
    @username = admin_name
    @password = admin_password
    @timeout = timeout
    
    @rest_agent = RestAgent.new("http://#{@ip}:#{@port}", username: @username, password: @password)
  end
  
  def get_schemas(node_name)
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(response.code, JSON.parse(response.body)['schemas']['schema'])
    netconf_response
  end
end