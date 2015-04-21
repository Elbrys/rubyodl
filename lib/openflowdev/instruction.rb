class Instruction
  attr_accessor :order
  attr_reader :actions
  
  def initialize(instruction_order: nil)
    @order = instruction_order
    @actions = []
  end
  
  def add_apply_action(action)
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