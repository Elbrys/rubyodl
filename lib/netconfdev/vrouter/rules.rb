class Rules
  attr_reader :name, :rules
  
  def initialize(name: nil)
    raise ArgumentError, "Name (name) required" unless name
    
    @name = name
    @rules = []
  end
  
  def add_rule(rule)
    raise ArgumentError, "Rule must be instance of 'Rule'" unless rule.is_a?(Rule)
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