class Action
  attr_accessor :order
  
  def initialize(order: nil)
    @order = order
  end
end