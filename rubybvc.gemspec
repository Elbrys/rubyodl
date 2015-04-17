Gem::Specification.new do |s|
  s.name        = 'rubybvc'
  s.version     = '0.1.0'
  s.date        = '2015-04-10'
  s.summary     = "Ruby BVC"
  s.description = "Ruby support library for Brocade Vyatta Controller (BVC) RESTCONF API"
  s.authors     = ["Elbrys Networks"]
  s.email       = 'support@elbrys.com'
  s.files       = ["lib/rubybvc.rb", "lib/controller/controller.rb",
    "lib/controller/netconf_node.rb", "lib/openflowdev/action.rb",
    "lib/openflowdev/drop_action.rb", "lib/openflowdev/flow_entry.rb",
    "lib/openflowdev/instruction.rb", "lib/openflowdev/match.rb",
    "lib/openflowdev/of_switch.rb", "lib/openflowdev/output_action.rb",
    "lib/utils/hash_with_compact.rb", "lib/utils/netconf_response.rb",
    "lib/utils/netconf_response_status.rb", "lib/utils/rest_agent.rb"]
  s.homepage    = '' # github link
  s.license     = 'BSD'
  s.add_runtime_dependency "nokogiri", ["= 1.6.6.2"]
end