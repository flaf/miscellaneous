Puppet::Functions.create_function(:'network::dump_addr') do

  dispatch :dump_addr do
    required_param 'String[1]', :addr_str
    required_param 'String[1]', :netmask_str
  end

  def dump_addr(addr_str, netmask_str)

    require 'ipaddr'

    function_name = 'dump_addr'

    begin
      network_addr = IPAddr.new(addr_str + '/' + netmask_str)
    rescue ArgumentError
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the `#{addr_str}` address and
        |and the `#{netmask_str}` netmask don't give a valid
        |CIDR address after concatenation.
        EOS
      raise(Puppet::ParseError, msg)
    end

    addr_str.strip!
    netmask_str.strip!

    if not netmask_str =~ Regexp.new('^\d+$')
      # The netmask argument is an integer.
      mask_num = netmask_str
    else
      # The netmask argument is an IP address.
      # TODO: maybe there is a proper way to get the
      # mask number.
      mask_num = IPAddr.new(netmask_str).to_i.to_s(2).count('1').to_s
    end

    { 'address'        => addr_str,
      'network'        => network_addr.to_s,
      'broadcast'      => network_addr.to_range.last.to_s,
      'netmask'        => netmask_str,
      'cidr'           => addr_str + '/' + mask_num,
      'netmask_length' => mask_num,
    }

  end

end


