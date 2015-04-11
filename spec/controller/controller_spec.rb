require 'spec_helper'
require 'controller/controller'

RSpec.describe Controller do
  let(:controller) { Controller.new(ip_addr: '1.2.3.4', port_number: '1234', admin_name: 'username', admin_password: 'password')}
  it 'gets a list of schemas for a particular node' do
    node_name = "that-node"
    schemas = {:schemas => {:schema => [{:identifier => 'schema-identifier',
        :version => '2015-04-10', :format => 'ietf-netconf-monitoring:yang',
        :location => ['NETCONF'],
        :namespace => 'urn:opendaylight:schema:namespace'}]}}.to_json
    WebMock.stub_request(:get,
      ("http://#{controller.username}:#{controller.password}@" \
        "#{controller.ip}:#{controller.port}/restconf/operational/" \
        "opendaylight-inventory:nodes/node/#{node_name}/"\
        "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
      to_return(:body => schemas)
    
    response = controller.get_schemas(node_name)
    expect(response.status).to eq(200)
    expect(response.body).to eq(JSON.parse(schemas)["schemas"]["schema"])
  end
end