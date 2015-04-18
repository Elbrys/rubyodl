def check_response_for_success(response)
  netconf_response = nil
  if response && ((response.body && response.code.to_i < 204) || (response.code.to_i == 204 && !response.body))
    parsed_body = response.body ? JSON.parse(response.body) : nil
    netconf_response = yield parsed_body
  else
    netconf_response = handle_error_response(response)
  end
  netconf_response
end

def handle_error_response(response)
  if response && response.body.nil? && response.code.to_i < 204
    netconf_response = NetconfResponse.new(NetconfResponseStatus::CTRL_INTERNAL_ERROR)
  elsif response && response.code.to_i > 204
    netconf_response = NetconfResponse.new(NetconfResponseStatus::HTTP_ERROR,
       response)
  elsif !response
    netconf_response = NetconfResponse.new(NetconfResponseStatus::CONN_ERROR)
  end
end