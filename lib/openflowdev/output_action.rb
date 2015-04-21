class OutputAction < Action
  def initialize(order: 0, port: nil, max_length: nil)
    @order = order
    @port = port
    @max_length = max_length
  end
  
  def to_hash
    {:order => @order, 'output-action' => {'max-length' => @max_length,
      'output-node-connector' => @port}}
  end
end