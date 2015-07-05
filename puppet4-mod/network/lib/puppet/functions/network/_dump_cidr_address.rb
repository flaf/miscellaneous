Puppet::Functions.create_function(:'network::_dump_cidr_address') do

  dispatch :_dump_cidr_address do
    required_param 'String[1]', :cidr_address_str
  end

  def _dump_cidr_address(cidr_address_str)

    require 'ipaddr'
    function_name = '_dump_cidr_address'

    msg_cidr_not_valid = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the `#{cidr_address_str}` string
      |is not a valid CIDR address (which must match at least
      |this regexp `^[^/]+/\d+$`).
      EOS

    if not cidr_address_str =~ Regexp.new('^[^/]+/\d+$')
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    ip_address_str = cidr_address_str.split('/')[0]
    mask_num       = cidr_address_str.split('/')[1]

    begin
      ip_address      = IPAddr.new(ip_address_str)
      # With the CIDR string, the address is automatically masked.
      network_address = IPAddr.new(cidr_address_str)
    rescue ArgumentError
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    # For the netmask address, I have no way except to
    # handle 2 cases: the address is an IPv4 address or
    # an IPv6 address.
    if ip_address.ipv4?
      netmask_address = IPAddr.new('0.0.0.0').~().mask(mask_num)
    else
      # It's a IPv6 adddress.
      netmask_address = IPAddr.new('::').~().mask(mask_num)
    end

    {
      'ip_address'        => ip_address.to_s,
      'network_address'   => network_address.to_s,
      'broadcast_address' => network_address.to_range.last.to_s,
      'netmask_address'   => netmask_address.to_s
    }

  end

end


