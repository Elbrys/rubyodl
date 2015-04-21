class OFSwitch
  require 'json'
  require 'controller/controller'
  require 'openflowdev/flow_entry'
  require 'openflowdev/action_output'
  
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
    get_uri = "#{@controller.get_node_operational_uri(self)}/node-connector/"\
      "#{self.name}:#{port}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('node-connector') &&
          body['node-connector'].is_a?(Array) && body['node-connector'][0]
        NetconfResponse.new(NetconfResponseStatus::OK, body['node-connector'][0])
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
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
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
  
  def get_operational_flows(table_id: nil)
    get_flows(table_id: table_id)
  end
  
  def get_configured_flows(table_id: nil)
    get_flows(table_id: table_id, is_operational: false)
  end
  
  def get_operational_flows_ovs_syntax(table_id: nil, sort: false)
    response = get_operational_flows(table_id: table_id)
    if response.status == NetconfResponseStatus::OK
      flows = []
      response.body.sort! { |x,y| x['priority'] <=> y['priority']} if sort
      response.body.each do |flow|
        flows << odl_to_ovs_flow_syntax(flow)
      end
      NetconfResponse.new(NetconfResponseStatus::OK, flows)
    else
      response
    end
  end
  
  def get_configured_flows_ovs_syntax(table_id: nil, sort: false)
    response = get_configured_flows(table_id: table_id)
    if response.status == NetconfResponseStatus::OK
      flows = []
      response.body.sort! { |x,y| x['priority'] <=> y['priority']} if sort
      response.body.each do |flow|
        flows << odl_to_ovs_flow_syntax(flow)
      end
      NetconfResponse.new(NetconfResponseStatus::OK, flows)
    else
      response
    end
  end
  
  private
  
  def get_flows(table_id: nil, is_operational: true)
    if is_operational
      get_uri = "#{@controller.get_node_operational_uri(self)}/"\
        "flow-node-inventory:table/#{table_id}"
    else
      get_uri = "#{@controller.get_node_config_uri(self)}/"\
        "flow-node-inventory:table/#{table_id}"
    end
    
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('flow-node-inventory:table') &&
          body['flow-node-inventory:table'].is_a?(Array) &&
          body['flow-node-inventory:table'][0].has_key?('flow') &&
          body['flow-node-inventory:table'][0]['flow'].is_a?(Array)
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['flow-node-inventory:table'][0]['flow'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def odl_to_ovs_flow_syntax(odl_flow)
    ovs_flow = {}
    if odl_flow.has_key?('cookie')
      ovs_flow['cookie'] = "0x#{odl_flow['cookie'].to_s(16)}"
    end
    
    if odl_flow.has_key?('opendaylight-flow-statistics:flow-statistics')
      stats = odl_flow['opendaylight-flow-statistics:flow-statistics']
      if stats.has_key?('duration')
        nanoseconds = stats['duration']['nanosecond'] ||= 0
        seconds = stats['duration']['second'] ||= 0
        duration = ((seconds * 1000000000 + nanoseconds).to_f / 1000000000.to_f)
        ovs_flow['duration'] = "#{duration}s"
      end
      
      if stats.has_key?('byte-count')
        ovs_flow['n_bytes'] = stats['byte-count']
      end
      
      if stats.has_key?('packet-count')
        ovs_flow['n_packets'] = stats['packet-count']
      end
    end
    
    if odl_flow.has_key?("table_id")
      ovs_flow['table'] = odl_flow['table_id']
    end
    
    if odl_flow.has_key?('idle-timeout')
      ovs_flow['idle_timeout'] = odl_flow['idle-timeout'] if odl_flow['idle-timeout'] != 0
    end
    
    if odl_flow.has_key?('hard-timeout')
      ovs_flow['hard_timeout'] = odl_flow['hard-timeout'] if odl_flow['hard-timeout'] != 0
    end
    
    if odl_flow.has_key?('priority')
      ovs_flow['priority'] = odl_flow['priority']
    end
    
    if odl_flow.has_key?('match')
      match = odl_flow['match']
      if match.has_key?('in-port')
        ovs_flow['in_port'] = match['in-port'].partition("#{@name}:")[2]
      end
      
      if match.has_key?('vlan-match')
        vlan_match = match['vlan-match']
        if vlan_match.has_key?('vlan-id') &&
            vlan_match['vlan-id'].has_key?('vlan-id')
          ovs_flow['dl_vlan'] = vlan_match['vlan-id']['vlan-id']
        end
        
        if vlan_match.has_key?('vlan-pcp')
          ovs_flow['dl_vlan_pcp'] = vlan_match['vlan-pcp']
        end
      end
      
      if match.has_key?('ethernet-match')
        eth_match = match['ethernet-match']
        if eth_match.has_key?('ethernet-type') &&
            eth_match['ethernet-type'].has_key?('type')
          ovs_flow['dl_type'] = "0x#{eth_match['ethernet-type']['type'].to_s(16)}"
        end
        
        if eth_match.has_key?('ethernet-source') &&
            eth_match['ethernet-source'].has_key?('address')
          ovs_flow['dl_src'] = eth_match['ethernet-source']['address']
        end
        
        if eth_match.has_key?('ethernet-destination') &&
            eth_match['ethernet-destination'].has_key?('address')
          ovs_flow['dl_dst'] = eth_match['ethernet-destination']['address']
        end
      end
      
      if match.has_key?('ip-match')
        ip_match = match['ip-match']
        if ip_match.has_key?('ip-protocol')
          ovs_flow['nw_proto'] = ip_match['ip-protocol']
        end
      end
      
      if match.has_key?('tcp-source-port')
        ovs_flow['tp_src'] = match['tcp-source-port']
      end
      
      if match.has_key?('ipv4-source')
        ovs_flow['nw_src'] = match['ipv4-source']
      end
      
      if match.has_key?('ipv4-destination')
        ovs_flow['nw_dst'] = match['ipv4-destination']
      end
    end
    
    if odl_flow.has_key?('instructions') &&
        odl_flow['instructions'].has_key?('instruction')
      odl_flow['instructions']['instruction'].each do |instruction|
        if instruction.has_key?('apply-actions') &&
            instruction['apply-actions'].has_key?('action')
          actions_list = []
          instruction['apply-actions']['action'].each do |action|
            if action.has_key?('output-action')
              ao = ActionOutput.new
              ao.update_from_object(action)
              actions_list << ao
            end
          end
          actions_list.sort! { |x, y| x.order <=> y.order}
          actions = []
          actions_list.each do |action|
            actions << action.to_s
          end
          ovs_flow['actions'] = actions.join(',')
        end
      end
    else
      # ODL flows do not seem to contain the instructions info for flows that
      # were set with 'drop'
      ovs_flow['actions'] = 'drop'
    end
    
    ovs_flow
  end
end