class SetQueueAction < Action
  def initialize(order: nil, queue: nil, queue_id: nil)
    super(order: order)
    raise ArgumentError, "Queue (queue) required" unless queue
    raise ArgumentError, "Queue ID (queue_id) required" unless queue_id
    @queue = queue
    @queue_id = queue
  end
  
  def to_hash
    {:order => @order, 'queue-action' => {:queue => @queue,
        'queue-id' => @queue_id}}
  end
end