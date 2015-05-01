require 'openflowdev/actions/action'

class DropAction < Action
  def to_hash
    {:order => @order, 'drop-action' => {}}
  end
end