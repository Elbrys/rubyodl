class SetVlanCfiAction < Action
  def initialize(order: nil, vlan_cfi: nil)
    super(order: order)
    raise ArgumentError, "VLAN CFI (vlan_cfi) required" unless vlan_cfi
    @vlan_cfi = vlan_cfi
  end
  
  def to_hash
    {:order => @order, 'set-vlan-cfi-action' => {'vlan-cfi' => @vlan_cfi}}
  end
end