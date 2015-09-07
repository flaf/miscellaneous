Puppet::Functions.create_function(:'network::fill_interfaces') do

  dispatch :fill_interfaces do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :interfaces
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :inventory_networks
  end

  def has_default_value(interface)
    interface.each do |k, v|
      if v == '__default__'
        return true
      
      end
    end
  end

  def no_in_netwoks(ifname, param, default_str, function_name)
    msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the interface `#{ifname}` has a #{default_str}
      |value for the `#{param}` parameter but has no `in_networks` key
      |provided. So the value can't be updated.
    EOS
    raise(Puppet::ParseError, msg)
  end

  def value_not_found(ifname, param, default_str, network, function_name)
    msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |#{function_name}(): the interface `#{ifname}` has a #{default_str}
      |value for the `#{param}` parameter but this parameter is not found
      |in the network `#{network}`.
    EOS
    raise(Puppet::ParseError, msg)
  end

  def fill_interfaces(interfaces, inventory_networks)

    #call_function("::network::check_interfaces", interfaces)
    #call_function("::network::fill_interfaces", interfaces)   # TODO
    function_name = 'fill_interfaces'
    ifaces_new    = {}
    default_str   = '__default__'

    interfaces.each do |ifname, settings|

      ifaces_new[ifname] = {}

      if settings.has_key?('in_networks')
        default_network                   = inventory_networks[settings['in_networks'][0]]
        ifaces_new[ifname]['in_networks'] = settings['in_networks']
      end

      if settings.has_key?('macaddress')
        if settings['macaddress'] == default_str
          if default_network.has_key?('macaddress')
            ifaces_new[ifname]['macaddress'] = default_network['macaddress']
          else
            
          end
        end
      end

    end

  end

end


