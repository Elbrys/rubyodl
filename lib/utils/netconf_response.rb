class NetconfResponse
  require 'utils/netconf_response_status'
  
  attr_accessor :status
  attr_accessor :body
  
  def initialize(netconf_response_status = nil, json_body = nil)
    @status = netconf_response_status
    @body = json_body
  end
  
  def message
    case(@status)
    when NetconfResponseStatus::OK
      "Success"
    when NetconfResponseStatus::NODE_CONNECTED
      "Node is connected"
    when NetconfResponseStatus::NODE_DISCONNECTED
      "Node is disconnected"
    when NetconfResponseStatus::NODE_NOT_FOUND
      "Node not found"
    when NetconfResponseStatus::NODE_CONFIGURED
      "Node is configured"
    when NetconfResponseStatus::CONN_ERROR
      "Server connection error"
    when NetconfResponseStatus::CTRL_INTERNAL_ERROR
      "Internal server error"
    when NetconfResponseStatus::HTTP_ERROR
      msg = "HTTP error"
      msg += " #{@body.code}" if @body.code
      msg += " - #{@body.message}" if @body.message
      msg
    when NetconfResponseStatus::DATA_NOT_FOUND
      "Requested data not found"
    end
  end
end