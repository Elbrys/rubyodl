class SetDlDstAction < Action
  def initialize(order: nil, mac_addr: nil)
    super(order: order)
    raise ArgumentError, "MAC Address (mac_addr) required"
    @mac = mac_addr
  end
  
  def to_hash
    {:order => @order, 'set-dl-dst-action' => {:address => @mac}}
  end
end