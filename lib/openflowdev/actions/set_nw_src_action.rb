class SetNwSrcAction < Action
  def initialize(order: nil, ip_addr: nil)
    super(order: order)
    raise ArgumentError, "IP Address (ip_addr) required" unless ip_addr
    @ip = ip_addr
  end
  
  def to_hash
    {:order => @order, 'set-nw-src-action' => {:address => @ip}}
  end
end