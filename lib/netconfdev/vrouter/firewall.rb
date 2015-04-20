class Firewall
  attr_reader :rules
  
  def initialize
    @rules = nil
  end
  
  def add_rules(rules_array)
    @rules = rules_array
  end
  
  def to_hash
    {'vyatta-security:security' => {'vyatta-security-firewall:firewall' =>
          {:name => [@rules.to_hash]}}}
  end
end