class FloodAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'flood-action' => {}}
  end
end