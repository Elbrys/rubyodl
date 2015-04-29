class DataplaneFirewall
  def initialize(interface_name: nil, in_firewall_name: nil, out_firewall_name: nil)
    @name = interface_name
    @in_firewall = in_firewall_name
    @out_firewall = out_firewall_name
  end
  
  def get_uri
    "/vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{@name}"
  end
  
  def to_hash
    {'vyatta-interfaces-dataplane:dataplane' => {:tagnode => @name,
      'vyatta-security-firewall:firewall' => {:in => [@in_firewall],
        :out => [@out_firewall]}}}
  end
end