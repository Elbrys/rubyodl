class Rule
  attr_reader :number, :action, :src_address
  
  def initialize(rule_number: nil, action: nil, source_address: nil)
    @number = rule_number
    @action = action
    @src_address = source_address
  end
  
  def to_hash
    {:action => @action, :source => {:address => @src_address},
      :tagnode => @number}
  end
end