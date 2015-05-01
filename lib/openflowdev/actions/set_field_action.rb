class SetFieldAction < Action
  def initialize(order: 0, vlan_id: nil, mpls_label: nil)
    super(order: order)
    @vlan_id = vlan_id
    @mpls_label = mpls_label
  end
  
  def to_hash
    {:order => @order, 'set-field' => {'vlan-match' => {'vlan-id' =>
            {'vlan-id' => @vlan_id, 'vlan-id-present' => !@vlan_id.nil?}},
        'protocol-match-fields' => {'mpls-label' => @mpls_label}}}
  end
end