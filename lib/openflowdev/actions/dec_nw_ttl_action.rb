class DecNwTTLAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'dec-nw-ttl' => {}}
  end
end