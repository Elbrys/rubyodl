class Rule
  attr_reader :number, :action, :src_address
  
  def initialize(rule_number: nil, action: nil, source_address: nil,
    icmp_typename: nil)
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