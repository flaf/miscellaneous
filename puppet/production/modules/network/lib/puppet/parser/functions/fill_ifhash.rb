module Puppet::Parser::Functions
  newfunction(:fill_ifhash, :type => :rvalue, :doc => <<-EOS
TODO: write the doc of this function.
    EOS
  ) do |args|

    require 'ipaddr'

    num_args = 3
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'fill_ifhash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    # Hash which contains the properties of interfaces.
    ifhash = args[0]

    # Hash which contains the properties of inventoried networks.
    nethash = args[1]

    # List of meta_options names.
    meta_options = args[2]

    meta_options.each do |value|
      unless value.is_a?(String) and not value.empty?()
        raise(Puppet::ParseError, "fill_ifhash(): the `meta_options` " +
              'argument must be an array of non empty strings')
      end
    end

    ###########################
    ### Update the nethash. ###
    ###########################
    nethash.each do |network, properties|

      # The `cidr_address` property must exist.
      unless properties.has_key?('cidr_address')
        raise(Puppet::ParseError, "fill_ifhash(): the `#{network}` network " +
              'has no "cidr_address" property')
      end

      # We add the `address_obj` key in the `properties` hash.
      begin
         properties['address_obj'] = IPAddr.new(properties['cidr_address'])
      rescue ArgumentError
        raise(Puppet::ParseError, "fill_ifhash(): the `#{network}` network " +
              'has a `cidr_address` property with a bad syntax')
      end

      # We add the `network_name` key in the `properties` hash
      # which is mapped to the key of the network.
      properties['network_name'] = network

      # We update the nethash when a value is an array.
      properties.each do |name, value|
        if value.is_a?(Array)
          properties[name] = value.join(' ')
        end
      end

    end
    ### End of the "nethash" loop. ###

    ##########################
    ### Update the ifhash. ###
    ##########################
    ifhash.each do |iface, properties|

      # For each interface, the 'method' key must exist.
      unless properties.has_key?('method')
        raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` interface " +
              'has no `method` property')
      end

      # If the value is an array, we update the value to value.join(' ').
      properties.each do |name, value|
        if value.is_a?(Array)
          properties[name] = value.join(' ')
        end
      end

      if not properties.has_key?('address')
        cidr = false
      elsif not properties['address'].include?('/')
        cidr = false
      else
        cidr = true
      end

      #############################################################
      # Try to define `matching_network` and `default_properties` #
      # variables without and with a CIDR address.                #
      #############################################################
      matching_network = ''
      default_properties = {}

      if not cidr

        # In this case, we can find the matching network only if `network_name`
        # is present in `properties` hash.
        if properties.has_key?('network_name')
          if nethash.has_key?(properties['network_name'])
            matching_network = properties['network_name']
            default_properties = nethash[matching_network]
          else
            raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` " +
                  'interface has a `network_name` property which does not ' +
                  'match with any network.')
          end
        end

      #########################################
      # If 'address' value is a CIDR address, #
      # so we make specific handles.          #
      #########################################
      else # CIDR address

        begin
          ipaddr_network = IPAddr.new(properties['address'])
        rescue ArgumentError
          raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` interface " +
                'has an `address` property with a bad syntax')
        end

        array_address = properties['address'].split('/')
        address = array_address[0]
        bitmask_num = array_address[1]

        ipaddr_netmask = IPAddr.new('255.255.255.255/' + bitmask_num)

        # Update the IP address (without the '/xx').
        properties['address'] = address

        # Add the network if it doesn't exist.
        if not properties.has_key?('network')
          properties['network'] = ipaddr_network.to_s()
        end

        # Add the netmask if it doesn't exist.
        if not properties.has_key?('netmask')
          properties['netmask'] = ipaddr_netmask.to_s()
        end

        # Add the broadcast if it doesn't exist.
        if not properties.has_key?('broadcast')
          properties['broadcast'] = ipaddr_netmask.~().|(ipaddr_network).to_s()
        end

        # Search for networks which match with this interface address.
        matching_networks = []
        nethash.each do |network, nhash|
          if nhash['address_obj'].eql?(ipaddr_network)
            if properties.has_key?('network_name')
              if properties['network_name'] == nhash['network_name']
                # 'network_name' is matching, so the network is matching.
                matching_networks.push(network)
              end
            else
                # 'network_name' is not defined in the interface or in the
                # network, so we choose that the network is matching.
                matching_networks.push(network)
            end
          end
        end

        # Define the `default_properties` and `matching_network` variables.
        n = matching_networks.length
        if n == 0
          raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` interface " +
                'has a CIDR address but no matching network is found ' +
                '(check the CIDR address and the `network_name` property, ' +
                'if defined, of this interface)')
        elsif n > 1
          raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` interface " +
                'has a CIDR address but several matching networks are found ' +
                '(use the `network_name` property to discriminate the uniq ' +
                'matching network)')
        else
          matching_network = matching_networks[0]
          default_properties = nethash[matching_network]
        end

      end # End of "not cidr/cidr"

      # Update values equal to 'default'.
      properties.each do |name, value|
        if value == 'default'
          if matching_network == ''
            # This is the default value when no matching network was found.
            raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` " +
                  "interface has the `#{name}` property equal to 'default' " +
                  'but no matching network was found for this interface ' +
                  '(try to use a CIDR address and/or the `network_name` ' +
                  'property to catch a network)')
          end
          if default_properties.has_key?(name)
            properties[name] = default_properties[name]
          else
            raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` " +
                  "interface has the `#{name}` property equal to 'default' " +
                  'but this property is not defined in the ' +
                  "`#{matching_network}` matching network")
          end
        end
      end

      # Add the meta_options values if defined in the matching network.
      meta_options.each do |meta_option|
        if default_properties.has_key?(meta_option)
          if not properties.has_key?(meta_option)
            properties[meta_option] = default_properties[meta_option]
          end
        end
      end

      # This is a little exception, if the option is 'dns-search',
      # we replace the '@domain' sub-string by the 'domain' fact.
      if properties.has_key?('dns-search')
        properties['dns-search'].gsub!('@domain', lookupvar('domain'))
      end

    end
    ### End of the "ifhash" loop. ###

    ifhash

  end
end


