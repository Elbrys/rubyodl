class CopyTTLOutwardsAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'copy-ttl-out' => {}}
  end
end