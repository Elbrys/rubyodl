class Action
  attr_accessor :order
  
  def initialize(order: nil)
    raise ArgumentError, "Order (order) required" unless order
    
    @order = order
  end
end