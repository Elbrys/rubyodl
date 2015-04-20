class Rules
  attr_reader :name, :rules
  
  def initialize(name: nil)
    @name = name
    @rules = []
  end
  
  def add_rule(rule)
    @rules << rule
  end
  
  def to_hash
    rules_hash = []
    @rules.each do |rule|
      rules_hash << rule.to_hash
    end
    {:rule => rules_hash, :tagnode => @name}
  end
end