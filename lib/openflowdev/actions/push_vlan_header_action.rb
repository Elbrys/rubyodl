class PushVlanHeaderAction < Action
  def initialize(order: 0, eth_type: nil, tag: nil, pcp: nil, cfi: nil,
      vlan_id: nil)
    super(order: order)
    @eth_type = eth_type
    @tag = tag
    @pcp = pcp
    @cfi = cfi
    @vlan_id = vlan_id
  end
  
  def to_hash
    {:order => @order, 'push-vlan-action' => {'ethernet-type' => @eth_type,
      :tag => @tag, :pcp => @pcp, :cfi => @cfi, 'vlan-id' => @vlan_id}}
  end
end