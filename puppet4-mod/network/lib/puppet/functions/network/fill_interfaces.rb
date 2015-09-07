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

    call_function("::network::check_interfaces", interfaces)
    #call_function("::network::fill_interfaces", interfaces)   # TODO
    function_name   = 'fill_interfaces'
    ifaces_new      = {}
    default_str     = '__default__'
    default_network = nil

    interfaces.each do |ifname, settings|

      ifaces_new[ifname] = {}

      if settings.has_key?('in_networks')

        # Check that each network in the `in_networks` array
        # is really present in the `inventory_networks` hash.
        settings['in_networks'].each do |netname|
          unless inventory_networks.has_key?(netname)
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the interface `#{ifname}` has a
              |`in_networks` key which indicates that the interface
              |belongs to the `#{netname}` network but this network
              |is not present among the `inventory_networks` hash.
            EOS
            raise(Puppet::ParseError, msg)
          end
        end

        # Ok, each network really exists in inventory_networks.
        iface_networks  = settings['in_networks']
        default_network = iface_networks[0]

        # We add the in_networks key.
        ifaces_new[ifname]['in_networks'] = iface_networks

      end

      # We add the macaddress key if it exists.
      if settings.has_key?('macaddress')
        ifaces_new[ifname]['macaddress'] = settings['macaddress']
      end

      # Handle of the comment key.
      if settings.has_key?('comment')
        interface_comment = settings['comment']
      else
        interface_comment = []
      end
      if default_network.nil?
        # No information about the networks of the current interface.
        final_comment = interface_comment
      else
        # We build a comment from each network in iface_networks.
        
      end

    end

  end

end


