class Controller
  require 'json'
  require 'utils/rest_agent'
  require 'utils/netconf_response'
  require 'controller/netconf_node'
  require 'nokogiri'
  
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
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['schemas']['schema'])
    netconf_response
  end
  
  def get_schema(node_name, id: nil, version: nil)
    netconf_response = nil
    post_uri = "/restconf/operations/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:get-schema"
    post_body = {:input => {:identifier => id, :version => version,
        :format => 'yang'}}
    response = @rest_agent.post_request(post_uri, post_body)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['get-schema']['output']['data'])
    netconf_response
  end
  
  def get_service_providers_info
    netconf_response = nil
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:services"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['services']['service'])
  end
  
  def get_service_provider_info(provider_name)
    netconf_response = nil
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:services/service/#{provider_name}"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['service'])
  end
  
  def get_netconf_operations(node_name)
    netconf_response = nil
    get_uri = "/restconf/operations/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['operations'])
  end
  
  def get_all_modules_operational_state
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['modules']['module'])
  end
  
  def get_module_operations_state(module_type, module_name)
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules/module/"\
      "#{module_type}/#{module_name}"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)["module"])
  end
  
  def get_sessions_info(node_name)
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:netconf-state/"\
      "sessions"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)["sessions"])
  end
  
  def get_streams_info
    netconf_response = nil
    get_uri = "restconf/streams"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['streams'])
  end
  
  def get_all_nodes_in_config
    netconf_response = nil
    get_uri = "/restconf/config/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK,
      JSON.parse(response.body)['nodes']['node'])
  end
  
  def check_node_config_status(node_name)
    netconf_response = nil
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/#{node_name}"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::NODE_CONFIGURED,
      JSON.parse(response.body))
  end
  
  def check_node_conn_status(node_name)
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/#{node_name}"
    response = @rest_agent.get_request(get_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::NODE_CONNECTED)
  end
  
  def get_all_nodes_conn_status
    netconf_response = nil
    get_uri = "/restconf/operational/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    conn_list = []
    JSON.parse(response.body)['nodes']['node'].each do |node|
      conn_status = {:node => node['id'], :connected => node['netconf-node-inventory:connected']}
      conn_list << conn_status
    end
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK, conn_list)
  end
  
  def add_netconf_node(node)
    netconf_response = nil
    post_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "contoroller-config/yang-ext:mount/config:modules"
    post_body = generate_node_xml(node)    
    response = @rest_agent.post_request(post_uri, post_body)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK)
  end
  
  def delete_netconf_node(node)
    netconf_response = nil
    delete_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules/module/"\
      "odl-sal-netconf-connector-cfg:sal-netconf-connector/#{node.name}"
    response = @rest_agent.delete_request(delete_uri)
    netconf_response = NetconfResponse.new(NetconfResponseStatus::OK)
  end
  
  private
  
  def node_namespace_prefix
    "urn:opendaylight:params:xml:ns:yang:controller"
  end
  
  def node_namespace
    "#{node_namespace_prefix}:md:sal:connector:netconf"
  end
  
  def generate_node_xml(node)
    builder = Nokogiri::XML::Builder.new { |xml|
      xml.module(:xmlns => "#{node_namespace_prefix}:config") {
        xml.type('xmlns:prefix' => node_namespace) {
          "prefix:sal-netconf-connector"
        }
        xml.name node.name
        xml.address node.ip, :xmlns => node_namespace
        xml.port node.port, :xmlns => node_namespace
        xml.username node.username, :xmlns => node_namespace
        xml.password node.password, :xmlns => node_namespace
        xml.send(:'tcp-only', node.tcp_only, :xmlns => node_namespace)
        xml.send(:'event-executor', :xmlns => node_namespace) {
          xml.type "prefix:netty-event-executor",
            'xmlns:prefix' => "#{node_namespace_prefix}:netty"
          xml.name "global-event-executor"
        }
        xml.send(:'binding-registry', :xmlns => node_namespace) {
          xml.type "prefix:binding-broker-osgi-registry",
            'xmlns:prefix' => "#{node_namespace_prefix}:md:sal:binding"
          xml.name "binding-osgi-broker"
        }
        xml.send(:'dom-registry', :xmlns => node_namespace) {
          xml.type "prefix:dom-broker-osgi-registry",
            'xmlns:prefix' => "#{node_namespace_prefix}:md:sal:dom"
          xml.name "dom-broker"
        }
        xml.send(:'client-dispatcher', :xmlns => node_namespace) {
          xml.type "prefix:netconf-client-dispatcher",
            'xmlns:prefix' => "#{node_namespace_prefix}:config:netconf"
          xml.name "global-netconf-dispatcher"
        }
        xml.send(:'processing-executor', :xmlns => node_namespace) {
          xml.type "prefix:threadpool",
            'xmlns:prefix' => "#{node_namespace_prefix}:threadpool"
          xml.name "global-netconf-processing-executor"
        }
      }
    }
    builder.to_xml
  end
end