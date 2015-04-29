class Firewall
  attr_reader :rules
  
  def initialize(rules: nil)
    @rules = rules
  end
  
  def to_hash
    {'vyatta-security:security' => {'vyatta-security-firewall:firewall' =>
          {:name => [@rules.to_hash]}}}
  end
end