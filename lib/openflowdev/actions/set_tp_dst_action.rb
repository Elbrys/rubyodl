class SetTpDstAction < Action
  def initialize(order: nil, port: nil)
    super(order: order)
    raise ArgumentError, "Port (port) required" unless port
    @port = port
  end
  
  def to_hash
    {:order => order, 'set-tp-dst-action' => {:port => @port}}
  end
end