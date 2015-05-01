class VRouter5600 < NetconfNode
  require 'netconfdev/vrouter/firewall'
  require 'netconfdev/vrouter/rules'
  require 'netconfdev/vrouter/rule'
  require 'netconfdev/vrouter/dataplane_firewall'
  
  def get_schemas
    @controller.get_schemas(@name)
  end
  
  def get_schema(id: nil, version: nil)
    raise ArgumentError, "Identifier (id) required" unless id
    raise ArgumentError, "Version (version) required" unless version
    
    @controller.get_schema(@name, id: id, version: version)
  end
  
  def get_cfg
    get_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
  
  def get_firewalls_cfg
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
  
  def get_firewall_instance_cfg(firewall_or_name)
    firewall_name = firewall_or_name.is_a?(Firewall) ? firewall_or_name.rules.name :
      firewall_or_name 
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
  
  def create_firewall_instance(firewall)
    raise ArgumentError, "Firewall must be instance of 'Firewall'" unless firewall.is_a?(Firewall)
    post_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.post_request(post_uri, firewall.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    check_response_for_success(response) do
      NetconfResponse.new(NetconfResponseStatus::OK)
    end
  end
  
  def delete_firewall_instance(firewall_or_name)
    firewall_name = firewall_or_name.is_a?(Firewall) ? firewall_or_name.rules.name :
      firewall_or_name
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.delete_request(delete_uri)
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end
  
  def get_dataplane_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-dataplane:dataplane')
        dp_interface_list = []
        body['interfaces']['vyatta-interfaces-dataplane:dataplane'].each do |interface|
          dp_interface_list << interface['tagnode']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, dp_interface_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_dataplane_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-dataplane:dataplane')
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['interfaces']['vyatta-interfaces-dataplane:dataplane'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_dataplane_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
  
  def get_loopback_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-loopback:loopback')
        lb_interface_list = []
        body['interfaces']['vyatta-interfaces-loopback:loopback'].each do |interface|
          lb_interface_list << interface['tagnode']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, lb_interface_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_loopback_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-loopback:loopback')
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['interfaces']['vyatta-interfaces-loopback:loopback'])
      end
    end
  end
  
  def get_loopback_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-loopback:loopback/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
  
  def set_dataplane_interface_firewall(interface_name,
      inbound_firewall_name: nil, outbound_firewall_name: nil)
    raise ArgumentError, "At least one firewall (inbound_firewall_name, "\
      "outbound_firewall_name) required" unless inbound_firewall_name || outbound_firewall_name
    dpif = DataplaneFirewall.new(interface_name: interface_name,
      in_firewall_name: inbound_firewall_name,
      out_firewall_name: outbound_firewall_name)
    
    put_uri = "#{@controller.get_ext_mount_config_uri(self)}/#{dpif.get_uri}"
    response = @controller.rest_agent.put_request(put_uri, dpif.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end
  
  def delete_dataplane_interface_firewall(interface_name)
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.delete_request(delete_uri)
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end
  
  def get_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash)
        if_list = []
        body['interfaces'].each do |if_name, interfaces|
          interfaces.each do |interface|
            if_list << interface['tagnode']
          end
        end
        NetconfResponse.new(NetconfResponseStatus::OK, if_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash)
        NetconfResponse.new(NetconfResponseStatus::OK, body)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  private
  
  def get_interfaces_config
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces"
    @controller.rest_agent.get_request(get_uri)
  end
end