Puppet::Functions.create_function(:'network::fill_interfaces') do

  # This function create a new version of the interfaces parameter
  # where the values '__default__' will be updated as described
  # in the documentation of this module.
  dispatch :fill_interfaces do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :interfaces
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :inventory_networks
  end

  def fill_interfaces(interfaces, inventory_networks)

    function_name   = 'fill_interfaces'

    call_function('::network::check_interfaces', interfaces)
    call_function('::network::check_inventory_networks', inventory_networks)
    ifaces_new      = call_function('::homemade::deep_dup', interfaces)
    default_str     = '__default__'

    ifaces_new.each do |ifname, settings|

      # Must be re-set at each loop to forget the parameters
      # of the previous interface.
      default_network = nil
      iface_networks  = nil

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

      end

      # Handle of the comment key.
      final_comment = []
      if not default_network.nil?
        # We build a comment from each network in iface_networks.
        final_comment += [ 'Interface in the network(s):' ]
        iface_networks.each do |netname|
          comment      = inventory_networks[netname]['comment']
          vlan_name    = inventory_networks[netname]['vlan_name']
          vlan_id      = inventory_networks[netname]['vlan_id']
          cidr_address = inventory_networks[netname]['cidr_address']
          comment      = comment.map { |line| '#' + ' '*18 + line }.join("\n")
          comment.sub!(/^# */, '')
          final_comment += [ "  [#{netname}]" ]
          final_comment += [ "    vlan_name => #{vlan_name}" ]
          final_comment += [ "    vlan_id   => #{vlan_id}" ]
          final_comment += [ "    CIDR      => #{cidr_address}" ]
          final_comment += [ "    comment   => #{comment}" ]
          #final_comment += comment.map { |line| '    ' + line }
        end
      end
      # We add the comment specific to the interface.
      if settings.has_key?('comment')
        final_comment += [ '--' ] + settings['comment']
      end
      # Update the comment.
      settings['comment'] = final_comment

      [ 'inet', 'inet6' ].each do |family|
        if not settings.has_key?(family) then next end
        if not settings[family].has_key?('options') then next end
        settings[family]['options'].each do |param, value|
          if value != default_str then next end
          if default_network.nil?
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the interface `#{ifname}` has a
              |`#{default_str}` value which must be updated but
              |the `in_networks` key is not provided for this interface.
            EOS
            raise(Puppet::ParseError, msg)
          end
          if [ 'network', 'netmask', 'broadcast' ].include?(param)
            cidr      = inventory_networks[default_network]['cidr_address']
            dump_cidr = call_function('::network::dump_cidr', cidr)
            settings[family]['options'][param] = dump_cidr[param]
          else
            if not inventory_networks[default_network].has_key?(param)
              msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): the interface `#{ifname}` has a
                |`#{default_str}` value which for the `#{param}` option
                |this option is not provided in the default network
                |`#{default_network}`.
              EOS
              raise(Puppet::ParseError, msg)
            end
            settings[family]['options'][param] = inventory_networks[default_network][param]
          end
        end
      end

    end # Loop on each interface.

    ifaces_new

  end

end


