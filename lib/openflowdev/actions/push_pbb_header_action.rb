class PushPBBHeaderAction < Action
  def initialize(order: 0, eth_type: nil)
    super(order: order)
    @eth_type = eth_type
  end
  
  def to_hash
    {:order => @order, 'push-pbb-aciton' => {'ethernet-type' => @eth_type}}
  end
end