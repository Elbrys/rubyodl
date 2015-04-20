class VRouter5600 < NetconfNode
  require 'netconfdev/vrouter/firewall'
  require 'netconfdev/vrouter/rules'
  require 'netconfdev/vrouter/rule'
  require 'netconfdev/vrouter/dataplane_firewall'
  
  def get_schemas
    @controller.get_schemas(@name)
  end
  
  def get_schema(id: nil, version: nil)
    @controller.get_schema(@name, id: id, version: version)
  end
  
  def get_cfg
    get_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
  
  def get_firewalls_cfg
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
  
  def get_firewall_instance(firewall_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
  
  def create_firewall_instance(firewall)
    post_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.post_request(post_uri, firewall.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    NetconfResponse.new(NetconfResponseStatus::OK)
  end
  
  def delete_firewall_instance(firewall)
    firewall_name = firewall.rules.name
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.delete_request(delete_uri)
    NetconfResponse.new(NetconfResponseStatus::OK)
  end
  
  def get_dataplane_interfaces_list
    response = get_interfaces_config
    dp_interface_list = []
    response.body['interfaces']['vyatta-interfaces-dataplane:dataplane'].each do |interface|
      dp_interface_list << interface['tagnode']
    end
    NetconfResponse.new(NetconfResponseStatus::OK, dp_interface_list)
  end
  
  def get_dataplane_interfaces_cfg
    response = get_interfaces_config
    NetconfResponse.new(NetconfResponseStatus::OK,
      response.body['interfaces']['vyatta-interfaces-dataplane:dataplane'])
  end
  
  def get_dataplane_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
  
  def get_loopback_interfaces_list
    response = get_interfaces_config
    lb_interface_list = []
    response.body['interfaces']['vyatta-interfaces-loopback:loopback'].each do |interface|
      lb_interface_list << interface['tagnode']
    end
    NetconfResponse.new(NetconfResponseStatus::OK, lb_interface_list)
  end
  
  def get_loopback_interfaces_cfg
    response = get_interfaces_config
    NetconfResponse.new(NetconfResponseStatus::OK,
      response.body['interfaces']['vyatta-interfaces-loopback:loopback'])
  end
  
  def get_loopback_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-loopback:loopback/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
  
  def set_dataplane_interface_firewall(interface_name,
      inbound_firewall_name: nil, outbound_firewall_name: nil)
    dpif = DataplaneFirewall.new(interface_name: interface_name,
      in_firewall_name: inbound_firewall_name,
      out_firewall_name: outbound_firewall_name)
    
    put_uri = "#{@controller.get_ext_mount_config_uri(self)}/#{dpif.get_uri}"
    response = @controller.rest_agent.put_request(put_uri, dpif.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    NetconfResponse.new(NetconfResponseStatus::OK)
  end
  
  def delete_dataplane_interface_firewall(interface_name)
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.delete_request(delete_uri)
    NetconfResponse.new(NetconfResponseStatus::OK)
  end

  private
  
  def get_interfaces_config
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces"
    response = @controller.rest_agent.get_request(get_uri)
    NetconfResponse.new(NetconfResponseStatus::OK, JSON.parse(response.body))
  end
end