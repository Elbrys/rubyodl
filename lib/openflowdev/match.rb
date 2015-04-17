class Match
  require 'utils/hash_with_compact'
  attr_reader :eth_type, :ipv4_dst, :ipv4_src, :ethernet_dst, :ethernet_src,
    :in_port, :ip_proto, :ip_dscp, :ip_ecn, :tcp_src_port, :tcp_dst_port,
    :udp_src_port, :udp_dst_port, :icmpv4_type, :icmpv4_code
  
  def initialize(eth_type: nil, ipv4_destination: nil, ipv4_source: nil,
      ethernet_destination: nil, ethernet_source: nil, in_port: nil,
      ip_protocol_num: nil, ip_dscp: nil, ip_ecn: nil, tcp_source_port: nil,
      tcp_destination_port: nil, udp_source_port: nil, udp_destination_port: nil,
      icmpv4_type: nil, icmpv4_code: nil)
    @eth_type = eth_type
    @ipv4_dst = ipv4_destination
    @ipv4_src = ipv4_source
    @ethernet_dst = ethernet_destination
    @ethernet_src = ethernet_source
    @in_port = in_port
    @ip_proto = ip_protocol_num
    @ip_dscp = ip_dscp
    @ip_ecn = ip_ecn
    @tcp_src_port = tcp_source_port
    @tcp_dst_port = tcp_destination_port
    @udp_dst_port = udp_destination_port
    @udp_src_port = udp_source_port
    @icmpv4_type = icmpv4_type
    @icmpv4_code = icmpv4_code
  end
  
  def to_hash
    hash = {'ethernet-match' => {'ethernet-type' => {:type => @eth_type},
      'ethernet-destination' => {:address => @ethernet_dst},
      'ethernet-source' => {:address => @ethernet_src}},
      'ipv4-destination' => @ipv4_dst, 'ipv4-source' => @ipv4_src,
      'in-port' => @in_port, 'ip-match' => {'ip-dscp' => @ip_dscp,
        'ip-ecn' => @ip_ecn, 'ip-protocol' => @ip_proto},
      'tcp-destination-port' => @tcp_dst_port,
      'tcp-source-port' => @tcp_src_port, 'udp-source-port' => @udp_src_port,
      'udp-destination-port' => @udp_dst_port, 'icmpv4-match' =>
        {'icmpv4-code' => @icmpv4_code, 'icmpv4-type' => @icmpv4_type}}
    hash = hash.compact
  end
end