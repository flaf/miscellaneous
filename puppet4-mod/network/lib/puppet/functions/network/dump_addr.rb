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
      raise(Puppet::ParseError, msg)
    end

    # TODO: maybe there is a proper way to get the
    # mask number
    mask_num = IPAddr.new(netmask_str).to_i.to_s(2).count('1')

    { 'address'        => addr_str.strip,
      'network'        => network_addr.to_s,
      'broadcast'      => network_addr.to_range.last.to_s,
      'netmask'        => netmask_str.strip,
      'cidr'           => addr_str + '/' + mask_num.to_s,
      'netmask_length' => mask_num.to_s,
    }

  end

end


