class ActionOutput
  attr_reader :type, :order, :port, :length
  
  def initialize(port: nil, length: nil, order: nil)
    @type = 'output'
    @order = order
    @port = port
    @length = length
  end
  
  def update(port: nil, length: nil, order: nil)
    @order = order unless order.nil?
    @port = port unless port.nil?
    @length = length unless length.nil?
  end
  
  def update_from_object(action_object)
    @order = action_object['order']
    if action_object.has_key?('output-action')
      if action_object['output-action'].has_key?('output-node-connector')
        @port = action_object['output-action']['output-node-connector']
      end
      
      if action_object['output-action'].has_key?('max-length')
        @length = action_object['output-action']['max-length']
      end
    end
  end
  
  def to_s
    if @port && @length
      if @port == "CONTROLLER"
        "#{@port}:#{@length}"
      else
        "#{@type}:#{@port}"
      end
    else
      ""
    end
  end
end