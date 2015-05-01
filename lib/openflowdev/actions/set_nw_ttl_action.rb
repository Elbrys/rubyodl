class SetNwTTLAction < Action
  def initialize(order: 0, ip_ttl: nil)
    super(order: order)
    raise ArgumentError, "IP TTL (ip_ttl) required" unless ip_ttl
    @ip_ttl = ip_ttl
  end
  
  def to_hash
    {:order => @order, 'set-nw-ttl-action' => {'nw-ttl' => @ip_ttl}}
  end
end