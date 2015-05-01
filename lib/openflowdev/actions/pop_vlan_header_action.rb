class PopVlanHeaderAction < Action
  def initialize(order: 0)
    super(order: order)
  end
  
  def to_hash
    {:order => @order, 'pop-vlan-action' => {}}
  end
end