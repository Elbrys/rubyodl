class OFSwitch
  require 'json'
  require 'controller/controller'
  require 'openflowdev/flow_entry'
  
  attr_reader :name
  
  def initialize(controller: nil, name: nil, dpid: nil)
    @controller = controller
    @name = name
    @dpid = dpid
  end
  
  def get_switch_info
    get_uri = @controller.get_node_operational_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      general_info = {}
      if body.has_key?('node') && body['node'].is_a?(Array)
        properties = body['node'][0]
        if properties.has_key?('flow-node-inventory:manufacturer')
          general_info['manufacturer'] = properties['flow-node-inventory:manufacturer']
        end
        if properties.has_key?('flow-node-inventory:serial-number')
          general_info['serial-number'] = properties['flow-node-inventory:serial-number']
        end
        if properties.has_key?('flow-node-inventory:software')
          general_info['software'] = properties['flow-node-inventory:software']
        end
        if properties.has_key?('flow-node-inventory:hardware')
          general_info['hardware'] = properties['flow-node-inventory:hardware']
        end
        if properties.has_key?('flow-node-inventory:description')
          general_info['description'] = properties['flow-node-inventory:description']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, general_info)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_features_info
    get_uri = @controller.get_node_operational_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('node') && body['node'].is_a?(Array) &&
          body['node'][0].has_key?('flow-node-inventory:switch-features')
        properties = body['node'][0]['flow-node-inventory:switch-features']
        feature_info = {'max_tables' => properties['max_tables'],
          'max_buffers' => properties['max_buffers']}
        capabilities = []
        properties['capabilities'].each do |capability|
          capabilities << capability.gsub('flow-node-inventory:flow-feature-capability-', '')
        end
        feature_info['capabilities'] = capabilities
        NetconfResponse.new(NetconfResponseStatus::OK, feature_info)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_ports_list
    get_uri = @controller.get_node_operational_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('node') && body['node'].is_a?(Array) &&
          body['node'][0].has_key?('node-connector')
        ports = []
        body['node'][0]['node-connector'].each do |port|
          ports << port['flow-node-inventory:port-number']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, ports)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_ports_brief_info
    get_uri = @controller.get_node_operational_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('node') && body['node'].is_a?(Array) &&
          body['node'][0].has_key?('node-connector')
        ports_info = []
        body['node'][0]['node-connector'].each do |port|
          port_info = {'id' => port['id'],
            'number' => port['flow-node-inventory:port-number'],
            'name' => port['flow-node-inventory:name'],
            'mac-address' => port['flow-node-inventory:hardware-address'],
            'current-feature' => port['flow-node-inventory:current-feature'].upcase}
          ports_info << port_info
        end
        NetconfResponse.new(NetconfResponseStatus::OK, ports_info)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_port_detail_info(port)
    get_uri = "#{@controller.get_node_operational_uri(self)}/node-controller/"\
      "#{self.name}:#{port}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.is_a?(Array) && body[0]
        NetconfResponse.new(NetconfResponseStatus::OK, body[0])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def add_modify_flow(flow)
    put_uri = "#{@controller.get_node_config_uri(self)}/table/#{flow.table_id}/"\
      "flow/#{flow.id}"
    response = @controller.rest_agent.put_request(put_uri, flow.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK)
    end
  end
  
  def get_configured_flow(table_id: nil, flow_id: nil)
    get_uri = "#{@controller.get_node_config_uri(self)}/table/#{table_id}/"\
      "flow/#{flow_id}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end
end