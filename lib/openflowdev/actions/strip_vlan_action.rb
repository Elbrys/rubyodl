class StripVlanAction < Action
  def to_hash
    {:order => @order, 'strip-vlan-action' => {}}
  end
end