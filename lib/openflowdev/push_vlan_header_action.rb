class PushVlanHeaderAction < Action
  def initialize(order: 0, eth_type: nil)
    @order = order
    @eth_type = eth_type
  end
  
  def to_hash
    {:order => @order, 'push-vlan-action' => {'ethernet-type' => @eth_type}}
  end
end