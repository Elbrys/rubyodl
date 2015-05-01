class CopyTTLInwardsAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'copy-ttl-in' => {}}
  end
end