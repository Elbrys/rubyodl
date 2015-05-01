class Rule
  attr_reader :number, :action, :src_address
  
  def initialize(rule_number: nil, action: nil, source_address: nil,
    icmp_typename: nil)
    raise ArgumentError, "Rule number (rule_number) required" unless rule_number
    raise ArgumentError, "Action (action) required" unless action
    # either of the other two required? at least one required?
    
    @number = rule_number
    @action = action
    @src_address = source_address
    @icmp_typename = icmp_typename
    @protocol = "icmp" if icmp_typename
  end
  
  def to_hash
    hash = {:action => @action, :source => {:address => @src_address},
      :tagnode => @number, :protocol => @protocol, :icmp =>
        {'type-name' => @icmp_typename}}
    hash.compact
  end
end