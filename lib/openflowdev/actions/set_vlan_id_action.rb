class SetVlanIdAction < Action
  def initialize(order: nil, vlan_id: nil)
    super(order: order)
    raise ArgumentError, "VLAN ID (vlan_id) required" unless vlan_id
    @vlan_id = vlan_id
  end
  
  def to_hash
    {:order => @order, 'set-vlan-id-action' => {'vlan-id' => @vlan_id}}
  end
end