class DecMplsTTLAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'dec-mpls-ttl' => {}}
  end
end