class FlowEntry
  require 'openflowdev/drop_action'
  require 'openflowdev/instruction'
  require 'openflowdev/match'
  
  attr_reader :table_id, :id, :priority, :idle_timeout, :hard_timeout, :strict,
    :install_hw, :barrier, :cookie, :cookie_mask, :name, :instructions, :match
  
  def initialize(flow_table_id: 0, flow_id: nil, flow_priority: nil, name: nil,
      idle_timeout: 0, hard_timeout: 0, strict: false, install_hw: false,
      barrier: false, cookie: nil, cookie_mask: nil)
    @table_id = flow_table_id
    @id = flow_id
    @name = name
    @priority = flow_priority
    @idle_timeout = idle_timeout
    @hard_timeout = hard_timeout
    @strict = strict
    @install_hw = install_hw
    @barrier = barrier
    @cookie = cookie
    @cookie_mask = cookie_mask
    @instructions = []
  end
  
  def add_instruction(instruction)
    @instructions << instruction
  end
  
  def add_match(match)
    @match = match
  end
  
  def to_hash
    instructions_hash = []
    @instructions.each do |instruction|
      instructions_hash << instruction.to_hash
    end
    
    hash = {'flow-node-inventory:flow' => {:barrier => @barrier,
      'hard-timeout' => @hard_timeout, :id => @id,
      'idle-timeout' => @idle_timeout, 'installHw' => @install_hw,
      :instructions => {:instruction => instructions_hash},
      :match => @match.to_hash, :priority => @priority,
      :strict => @strict, :table_id => @table_id, :cookie => @cookie,
      :cookie_mask => @cookie_mask, 'flow-name' => @name}}
    hash = hash.compact
    hash
  end
end