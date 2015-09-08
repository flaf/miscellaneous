Puppet::Functions.create_function(:'network::dump_cidr') do

  dispatch :dump_cidr do
    required_param 'String[1]', :cidr_str
  end

  def dump_cidr(cidr_str)

    require 'ipaddr'

    function_name = 'dump_cidr'

    msg_cidr_not_valid = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the `#{cidr_str}` string is not a
      |valid CIDR address.
      EOS

    # Check is cidr_str has this form 'xxx/yyy' with just
    # one slash.
    regex_one_slash = '^[^/]+/[^/]+$'
    if not cidr_str =~ Regexp.new(regex_one_slash)
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    ip_addr_str = cidr_str.split('/')[0] # part before "/"
    netmask_str = cidr_str.split('/')[1] # part after "/"

    begin
      ip_addr          = IPAddr.new(ip_addr_str)
      ip_addr_str      = ip_addr.to_s
      network_addr     = IPAddr.new(cidr_str)
      network_addr_str = network_addr.to_s
    rescue Exception
      raise(Puppet::ParseError, msg_cidr_not_valid)
    end

    # Now, we are sure that the cidr_str variable
    # is a valid CIDR address.

    if netmask_str =~ Regexp.new('^\d+$')
      # The netmask is just a number.

      # TODO: For the netmask address, I have found no way except
      # to handle 2 cases: the address is an IPv4 address or an
      # IPv6 address.
      if ip_addr.ipv4?
        zero_addr = '0.0.0.0'
      elsif ip_addr.ipv6?
        zero_addr = '::'
      else
        # Normally, you should never fall in this case.
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{cidr_str}` string is not a
          |valid CIDR address. It seems to not be a IPv4/IPv6 address.
          EOS
        raise(Puppet::ParseError, msg)

      end

      netmask_num_str  = netmask_str
      netmask_addr_str = IPAddr.new(zero_addr).~().mask(netmask_num_str).to_s
      cidr_str         = ip_addr_str + '/' + netmask_num_str
    else
      # The netmask is an IP address.

      netmask_addr_str = netmask_str.strip

      # Very curious but for example `IPAddr.new('192.168.3.4/255.205.0.0')`
      # doesn't raise an exception, however the netmask part is invalid.
      # We want to have an exception in this case.
      if not IPAddr.new(netmask_addr_str).to_i.to_s(2) =~ Regexp.new('^1*0*$')
        msg_mask_not_valid = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{cidr_str}` string is not a
          |valid CIDR address because the netmask part is an invalid
          |netmask address.
          EOS
        raise(Puppet::ParseError, msg_mask_not_valid)
      end

      netmask_num_str  = IPAddr.new(netmask_addr_str).to_i.to_s(2).count('1').to_s
      cidr_str         = ip_addr_str + '/' + netmask_num_str

    end

    { 'address'        => ip_addr_str,
      'network'        => network_addr_str,
      'broadcast'      => network_addr.to_range.last.to_s,
      'netmask'        => netmask_addr_str,
      'cidr'           => cidr_str,
      'netmask_num'    => netmask_num_str,
    }

  end

end


