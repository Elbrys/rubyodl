class NetconfResponse
  require 'utils/netconf_response_status'
  
  attr_accessor :status
  attr_accessor :body
  
  def initialize(netconf_response_status = nil, json_body = nil)
    @status = netconf_response_status
    @body = json_body
  end
end