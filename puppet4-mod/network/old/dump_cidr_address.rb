Puppet::Functions.create_function(:'network::dump_cidr_address') do

  dispatch :dump_cidr_address do
    required_param 'String[1]', :cidr_address_str
  end

  def dump_cidr_address(cidr_address_str)

    require 'ipaddr'

    function_name = 'dump_cidr_address'

    call_function('::network::check_cidr_address', cidr_address_str)

    ip_address_str  = cidr_address_str.split('/')[0]
    mask_num        = cidr_address_str.split('/')[1]
    ip_address      = IPAddr.new(ip_address_str)

    # With the CIDR string, the address is automatically masked.
    network_address = IPAddr.new(cidr_address_str)

    # For the netmask address, I have no way except to
    # handle 2 cases: the address is an IPv4 address or
    # an IPv6 address.
    if ip_address.ipv4?
      zero_addr = '0.0.0.0'
    else
      # It's a IPv6 adddress.
      # TODO: maybe add a `.ipv6?` test.
      zero_addr = '::'
    end
    netmask_address = IPAddr.new(zero_addr).~().mask(mask_num)

    {
      'ip_address'        => ip_address.to_s,
      'network_address'   => network_address.to_s,
      'broadcast_address' => network_address.to_range.last.to_s,
      'netmask_address'   => netmask_address.to_s
    }

  end

end


