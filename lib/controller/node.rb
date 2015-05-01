class Node
  attr_reader :name
  
  def initialize(controller: nil, name: nil)
    raise ArgumentError, "Controller (controller) required" unless controller
    raise ArgumentError, "Name (name) required" unless name
    raise ArgumentError, "Controller (controller) must be instance of 'Controller'" unless controller.is_a?(Controller)
    @controller = controller
    @name = name
  end
end