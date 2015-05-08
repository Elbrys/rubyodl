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

class ActionOutput
  attr_reader :type, :order, :port, :length
  
  def initialize(port: nil, length: nil, order: nil)
    @type = 'output'
    @order = order
    @port = port
    @length = length
  end
  
  def update(port: nil, length: nil, order: nil)
    @order = order unless order.nil?
    @port = port unless port.nil?
    @length = length unless length.nil?
  end
  
  def update_from_object(action_object)
    @order = action_object['order']
    if action_object.has_key?('output-action')
      if action_object['output-action'].has_key?('output-node-connector')
        @port = action_object['output-action']['output-node-connector']
      end
      
      if action_object['output-action'].has_key?('max-length')
        @length = action_object['output-action']['max-length']
      end
    end
  end
  
  def to_s
    if @port && @length
      if @port == "CONTROLLER"
        "#{@port}:#{@length}"
      else
        "#{@type}:#{@port}"
      end
    else
      ""
    end
  end
end