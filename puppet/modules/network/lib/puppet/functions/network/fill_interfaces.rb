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
    # TODO: PUP-5209
    #ifaces_new      = call_function('::homemade::deep_dup', interfaces)
    ifaces_new      = call_function('::network::deep_dup', interfaces)
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
      comment_from_networks = []
      if not default_network.nil?
        # We build a comment from each network in iface_networks.
        comment_from_networks += [ 'Interface in the network(s):' ]
        iface_networks.each do |netname|
          comment      = inventory_networks[netname]['comment']
          vlan_name    = inventory_networks[netname]['vlan_name']
          vlan_id      = inventory_networks[netname]['vlan_id']
          cidr_address = inventory_networks[netname]['cidr_address']
          # TODO: this formatting of the "comment" variable below is
          #       a bad thing. Indeed, the comment variable should
          #       keep the form "one line = one element of the array"
          #       and the formatting should be handled in the template.
          #       The "comment" variable should keep just the data
          #       without formatting.
          comment      = comment.map { |line| '#' + ' '*18 + line }.join("\n")
          comment.sub!(/^# */, '')
          comment_from_networks += [ "  [#{netname}]" ]
          comment_from_networks += [ "    vlan_name => #{vlan_name}" ]
          comment_from_networks += [ "    vlan_id   => #{vlan_id}" ]
          comment_from_networks += [ "    CIDR      => #{cidr_address}" ]
          comment_from_networks += [ "    comment   => #{comment}" ]
        end
      end
      # Creation of the final comment.
      if settings.has_key?('comment')
        if comment_from_networks.empty?
          final_comment = settings['comment']
        else
          final_comment = comment_from_networks + ['--'] + settings['comment']
        end
      else # No comment from the interface.
        if comment_from_networks.empty?
          final_comment = nil # No comment from networks and the interface.
        else
          final_comment = comment_from_networks # Comment from networks only.
        end
      end
      # Update the comment only if it's not nil.
      if not final_comment.nil?
        settings['comment'] = final_comment
      end

      # Handle of the __default__ value.
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
      end # Handle of __default__ values.

      # Handle of the "routes" entry.
      if settings.has_key?('routes')
        settings.each do |a_route|
        end
      end

    end # Loop on each interface.

    ifaces_new

  end

end


