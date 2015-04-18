class SetFieldAction < Action
  def initialize(order: 0, vlan_id: nil)
    @order = order
    @vlan_id = vlan_id
  end
  
  def to_hash
    {:order => @order, 'set-field' => {'vlan-match' => {'vlan-id' =>
            {'vlan-id' => @vlan_id, 'vlan-id-present' => !@vlan_id.nil?}}}}
  end
end