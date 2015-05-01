class SwPathAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'sw-path-action' => {}}
  end
end