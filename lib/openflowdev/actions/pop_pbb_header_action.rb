class PopPBBHeaderAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'pop-pbb-aciton' => {}}
  end
end