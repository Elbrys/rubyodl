class PushMplsHeaderAction < Action
  def initialize(order: 0, eth_type: nil)
    super(order: order)
    raise ArgumentError, "Ethernet Type (eth_type) required"
    @eth_type = eth_type
  end
  
  def to_hash
    {:order => @order, 'push-mpls-action' => {'ethernet-type' => @eth_type}}
  end
end