class Instruction
  attr_accessor :order
  attr_reader :actions
  
  def initialize(instruction_order: nil)
    raise ArgumentError, "Instruction Order (instruction_order) required" unless instruction_order
    @order = instruction_order
    @actions = []
  end
  
  def add_apply_action(action)
    raise ArgumentError, "Action must be a subclass of 'Action'" unless action.is_a?(Action)
    @actions << action
  end
  
  def to_hash
    actions_hash = []
    @actions.each do |action|
      actions_hash << action.to_hash
    end
    {:order => @order, 'apply-actions' => {:action => actions_hash}}
  end
end