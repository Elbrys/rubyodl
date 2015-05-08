# Copyright (c) 2015,  BROCADE COMMUNICATIONS SYSTEMS, INC
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

class Controller
  require 'json'
  require 'utils/rest_agent'
  require 'utils/netconf_response'
  require 'utils/utilities'
  require 'controller/netconf_node'
  require 'nokogiri'
  
  attr_reader :ip
  attr_reader :port
  attr_reader :username
  attr_reader :password
  attr_reader :timeout
  attr_reader :rest_agent
  
  def initialize(ip_addr: nil, port_number: 8181, admin_name: nil,
      admin_password: nil, timeout_in_s: 5)
    raise ArgumentError, "IP Address (ip_addr) required" unless ip_addr
    raise ArgumentError, "Admin Username (admin_name) required" unless admin_name
    raise ArgumentError, "Admin Password (admin_password) required" unless admin_password
    @ip = ip_addr
    @port = port_number
    @username = admin_name
    @password = admin_password
    @timeout = timeout_in_s
    
    @rest_agent = RestAgent.new("http://#{@ip}:#{@port}", username: @username,
      password: @password, open_timeout: @timeout)
  end
  
  def get_schemas(node_name)
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('schemas') && body['schemas'].has_key?('schema')
        NetconfResponse.new(NetconfResponseStatus::OK, body['schemas']['schema'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_schema(node_name, id: nil, version: nil)
    raise ArgumentError, "Identifier (id) required" unless id
    raise ArgumentError, "Version (version) required" unless version
    post_uri = "/restconf/operations/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:get-schema"
    post_body = {:input => {:identifier => id, :version => version,
        :format => 'yang'}}
    response = @rest_agent.post_request(post_uri, post_body)
    check_response_for_success(response) do |body|
      if body.has_key?('get-schema') && body['get-schema'].has_key?('output') &&
          body['get-schema']['output'].has_key?('data')
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['get-schema']['output']['data'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_service_providers_info
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:services"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('services') && body['services'].has_key?('service')
        NetconfResponse.new(NetconfResponseStatus::OK, body['services']['service'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_service_provider_info(provider_name)
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:services/service/#{provider_name}"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('service')
        NetconfResponse.new(NetconfResponseStatus::OK, body['service'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_netconf_operations(node_name)
    get_uri = "/restconf/operations/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('operations')
        NetconfResponse.new(NetconfResponseStatus::OK, body['operations'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_all_modules_operational_state
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules"
    response = @rest_agent.get_request(get_uri)
    response.body.gsub!("\\\n", "")
    check_response_for_success(response) do |body|
      if body.has_key?('modules') && body['modules'].has_key?('module')
        NetconfResponse.new(NetconfResponseStatus::OK, body['modules']['module'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_module_operational_state(type: nil, name: nil)
    raise ArgumentError, "Type (type) required" unless type
    raise ArgumentError, "Name (name) required" unless name
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules/module/"\
      "#{type}/#{name}"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('module')
        NetconfResponse.new(NetconfResponseStatus::OK, body["module"])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_sessions_info(node_name)
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}/yang-ext:mount/ietf-netconf-monitoring:netconf-state/"\
      "sessions"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('sessions')
        NetconfResponse.new(NetconfResponseStatus::OK, body["sessions"])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_streams_info
    get_uri = "restconf/streams"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('streams')
        NetconfResponse.new(NetconfResponseStatus::OK, body['streams'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_all_nodes_in_config
    get_uri = "/restconf/config/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        devices = []
        body['nodes']['node'].each do |node|
          devices << node['id']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, devices)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_netconf_nodes_in_config
    get_uri = "/restconf/config/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        devices = []
        body['nodes']['node'].each do |node|
          devices << node['id'] unless node['id'].include?('openflow')
        end
        NetconfResponse.new(NetconfResponseStatus::OK, devices)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_netconf_nodes_conn_status
    get_uri = "/restconf/operational/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        conn_list = []
        body['nodes']['node'].each do |node|
          unless node['id'].include?('openflow')
            conn_status = {:node => node['id'],
              :connected => node['netconf-node-inventory:connected']}
            conn_list << conn_status
          end
        end
        NetconfResponse.new(NetconfResponseStatus::OK, conn_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_nodes_operational_list
    get_uri = "/restconf/operational/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        list = []
        body['nodes']['node'].each do |node|
          list << node['id'] if node['id']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_openflow_nodes_operational_list
    get_uri = "/restconf/operational/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        filtered_list = []
        body['nodes']['node'].each do |node|
          filtered_list << node['id'] if node['id'].start_with?('openflow')
        end
        NetconfResponse.new(NetconfResponseStatus::OK, filtered_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def get_node_info(node_name)
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('node')
        NetconfResponse.new(NetconfResponseStatus::OK, body['node'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def check_node_config_status(node_name)
    get_uri = "/restconf/config/opendaylight-inventory:nodes/node/#{node_name}"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do
      NetconfResponse.new(NetconfResponseStatus::NODE_CONFIGURED,
        JSON.parse(response.body))
    end
  end
  
  def check_node_conn_status(node_name)
    get_uri = "/restconf/operational/opendaylight-inventory:nodes/node/"\
      "#{node_name}"
    response = @rest_agent.get_request(get_uri)
    if response.code.to_i == 404
      NetconfResponse.new(NetconfResponseStatus::NODE_NOT_FOUND)
    else
      check_response_for_success(response) do |body|
        connected = false
        if body.has_key?('node') && body['node'][0] && body['node'][0].has_key?('id')
          if body['node'][0].has_key?('netconf-node-inventory:connected')
            if body['node'][0]['netconf-node-inventory:connected']
              connected = true
            end
          end
        end
        if connected
          NetconfResponse.new(NetconfResponseStatus::NODE_CONNECTED)
        else
          NetconfResponse.new(NetconfResponseStatus::NODE_DISCONNECTED)
        end
      end
    end
  end
  
  def get_all_nodes_conn_status
    get_uri = "/restconf/operational/opendaylight-inventory:nodes"
    response = @rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      if body.has_key?('nodes') && body['nodes'].has_key?('node')
        conn_list = []
        body['nodes']['node'].each do |node|
          is_connected = false
          if node['id'].include?('openflow')
            # OpenFlow devices connect to controller (unlike NETCONF nodes),
            # so if we see one, then it is 'connected'
            is_connected = true
          elsif node.has_key?('netconf-node-inventory:connected')
            is_connected = node['netconf-node-inventory:connected']
          end
          conn_status = {:node => node['id'],
            :connected => is_connected}
          conn_list << conn_status
        end
        NetconfResponse.new(NetconfResponseStatus::OK, conn_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end
  
  def add_netconf_node(node)
    post_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules"
    post_body = generate_node_xml(node)    
    response = @rest_agent.post_request(post_uri, post_body,
      headers: {'Content-Type' => "application/xml",
        'Accept' => "application/xml"})
    check_response_for_success(response) do
        NetconfResponse.new(NetconfResponseStatus::OK)
    end
  end
  
  def delete_netconf_node(node)
    delete_uri = "/restconf/config/opendaylight-inventory:nodes/node/"\
      "controller-config/yang-ext:mount/config:modules/module/"\
      "odl-sal-netconf-connector-cfg:sal-netconf-connector/#{node.name}"
    response = @rest_agent.delete_request(delete_uri)
    # need to do the check here because there is no response body and the code
    # is a 200 instead of 204
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end
  
  def get_node_operational_uri(node)
    raise ArgumentError, "Node (node) must be a 'Node' object or a 'Node' "\
      "subclass object" unless node.is_a?(Node) ||
      (node.methods.include?(:ancestors) && node.ancestors.include?(Node))
    "/restconf/operational/opendaylight-inventory:nodes/node/#{node.name}"
  end
  
  def get_node_config_uri(node)
    raise ArgumentError, "Node (node) must be a 'Node' object or a 'Node' "\
      "subclass object" unless node.is_a?(Node) ||
      (node.methods.include?(:ancestors) && node.ancestors.include?(Node))
    "/restconf/config/opendaylight-inventory:nodes/node/#{node.name}"
  end
  
  def get_ext_mount_config_uri(node)
    raise ArgumentError, "Node (node) must be a 'Node' object or a 'Node' "\
      "subclass object" unless node.is_a?(Node)
    "/restconf/config/opendaylight-inventory:nodes/node/#{node.name}/yang-ext:mount"
  end
  
  def to_hash
    {:ip_addr => @ip, :port_num => @port, :admin_name => @username,
      :admin_password => @password}
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
        xml.type "prefix:sal-netconf-connector", 'xmlns:prefix' => node_namespace
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