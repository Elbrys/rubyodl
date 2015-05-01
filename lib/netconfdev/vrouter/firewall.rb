class Firewall
  attr_reader :rules
  
  def initialize(rules: nil)
    raise ArgumentError, "Rules (rules) required" unless rules
    raise ArgumentError, "Rules (rules) must be instance of 'Rules'" unless rules.is_a?(Rules)
    @rules = rules
  end
  
  def to_hash
    {'vyatta-security:security' => {'vyatta-security-firewall:firewall' =>
          {:name => [@rules.to_hash]}}}
  end
end