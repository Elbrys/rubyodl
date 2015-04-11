class NetconfResponse
  attr_accessor :status
  attr_accessor :body
  
  def initialize(code = nil, json_body = nil)
    @status = code.to_i
    @body = json_body
  end
end