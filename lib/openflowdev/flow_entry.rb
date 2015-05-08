# Copyright (c) 2015,  BROCADE COMMUNICATIONS SYSTEMS, INC
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

class FlowEntry
  require 'openflowdev/instruction'
  require 'openflowdev/match'
  
  attr_reader :table_id, :id, :priority, :idle_timeout, :hard_timeout, :strict,
    :install_hw, :barrier, :cookie, :cookie_mask, :name, :instructions, :match,
    :out_port, :out_group, :flags, :buffer_id
  
  def initialize(flow_table_id: 0, flow_id: nil, flow_priority: nil, name: nil,
      idle_timeout: 0, hard_timeout: 0, strict: false, install_hw: false,
      barrier: false, cookie: nil, cookie_mask: nil, out_port: nil,
      out_group: nil, flags: nil, buffer_id: nil)
    raise ArgumentError, "Flow ID (flow_id) required" unless flow_id
    raise ArgumentError, "Flow Priority (flow_priority) required" unless flow_priority
    
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
    @out_port = out_port
    @out_group = out_group
    @flags = flags
    @buffer_id = buffer_id
  end
  
  def add_instruction(instruction)
    raise ArgumentError, "Instruction must be of type 'Instruction'" unless instruction.is_a?(Instruction)
    @instructions << instruction
  end
  
  def add_match(match)
    raise ArgumentError, "Match must be of type 'Match'" unless match.is_a?(Match)
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
      'out-port' => @out_port, 'out-group' => @out_group, :flags => @flags,
      'buffer-id' => @buffer_id, :match => @match.to_hash, :priority => @priority,
      :strict => @strict, :table_id => @table_id, :cookie => @cookie,
      :cookie_mask => @cookie_mask, 'flow-name' => @name,
      :instructions => {:instruction => instructions_hash}}}
    hash = hash.compact
    hash
  end
end