class OutputAction < Action
  def initialize(order: 0, port: nil, max_length: 0)
    @order = order
    @port = port
    @max_length = max_length
  end
  
  def to_hash
    {:order => @order, :output_action => {'max-length' => max_length,
      'output-node-connector' => @port}}
  end
end