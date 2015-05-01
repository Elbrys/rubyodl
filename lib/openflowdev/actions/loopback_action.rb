class LoopbackAction
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'loopback_action' => {}}
  end
end