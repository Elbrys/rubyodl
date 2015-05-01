class PopMplsHeaderAction < Action
  def initialize(order: 0, eth_type: nil)
    super(order: order)
    raise ArgumentError, 'Ethernet Type (eth_type) required' unless eth_type
    @eth_type = eth_type
  end
  
  def to_hash
    {:order => @order, 'pop-mpls-action' => {'ethernet-type' => @eth_type}}
  end
end