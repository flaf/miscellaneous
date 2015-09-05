Puppet::Functions.create_function(:'network::dump_cidr') do

  dispatch :dump_cidr do
    required_param 'String[1]', :cidr_str
  end

  def dump_cidr(cidr_str)

    require 'ipaddr'

    function_name = 'dump_cidr'

    msg_cidr_not_valid = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the `#{cidr_str}` string is not a
      |valid CIDR address (which must match, at least,
      |this regexp `^[^/]+/\d+$`).
      EOS

    if not cidr_str =~ Regexp.new('^[^/]+/\d+$')
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    ip_addr_str  = cidr_str.split('/')[0]
    mask_num_str = cidr_str.split('/')[1]

    begin
      ip_addr      = IPAddr.new(ip_addr_str)
      network_addr = IPAddr.new(cidr_str)
    rescue ArgumentError
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    # Now, we are sure that the cidr_str variable
    # is a valid CIDR address.

    # For the netmask address, I have no way except to
    # handle 2 cases: the address is an IPv4 address or
    # an IPv6 address.
    if ip_addr.ipv4?
      netmask_addr = IPAddr.new('0.0.0.0').~().mask(mask_num_str)
    else
      # It's a IPv6 adddress.
      netmask_addr = IPAddr.new('::').~().mask(mask_num_str)
    end

    { 'address'        => ip_addr.to_s,
      'network'        => network_addr.to_s,
      'broadcast'      => network_addr.to_range.last.to_s,
      'netmask'        => netmask_addr.to_s,
      'cidr'           => cidr_str.strip,
      'netmask_length' => mask_num_str,
    }

  end

end


