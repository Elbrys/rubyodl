class SetMplsTTLAction < Action
  def initialize(order: 0, mpls_ttl: nil)
    super(order: order)
    raise ArgumentError, "MPLS TTL (mpls_ttl) required" unless mpls_ttl
    @mpls_ttl = mpls_ttl
  end
  
  def to_hash
    {:order => order, 'set-mpls-ttl-action' => {'mpls-ttl' => @mpls_ttl}}
  end
end