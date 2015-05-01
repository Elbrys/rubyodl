class GroupAction < Action
  def initialize(order: nil, group: nil, group_id: nil)
    super(order: order)
    raise ArgumentError, "Group (group) required" unless group
    raise ArgumentError, "Group ID (group_id) required" unless group_id
    @group = group
    @group_id = group_id
  end
  
  def to_hash
    {:order => @order, 'group-action' => {:group => @group,
        'group-id' => @group_id}}
  end
end