class SetVlanPCPAction < Action
  def initialize(order: nil, vlan_pcp: nil)
    super(order: order)
    raise ArgumentError, "VLAN PCP (vlan_pcp) required" unless vlan_pcp
    @vlan_pcp = vlan_pcp
  end
  
  def to_hash
    {:order => @order, 'set-vlan-pcp-action' => {'vlan-pcp' => @vlan_pcp}}
  end
end