class HwPathAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'hw-path-action' => {}}
  end
end