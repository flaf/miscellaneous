module Puppet::Parser::Functions
  newfunction(:complete_ifaces_hash, :type => :rvalue, :doc => <<-EOS
This function takes 3 arguments:
  - a "interfaces" hash;
  - a "networks" hash;
  - an array of meta options.
This function returns a new version of the "interfaces" hash
completed with information in the "networks" hash and in the
array of meta options.
    EOS
  ) do |args|

    require 'ipaddr'
    Puppet::Parser::Functions.function('check_ifaces_hash')
    Puppet::Parser::Functions.function('check_networks_hash')
    Puppet::Parser::Functions.function('get_network_name')
    Puppet::Parser::Functions.function('get_meta_options')

    num_args = 2
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'complete_ifaces_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    # Hash which contains the properties of interfaces.
    ifhash = args[0]

    # Hash which contains the properties of inventoried networks.
    nethash = args[1]

    # List of meta_options names.
    meta_options = function_get_meta_options([])

    function_check_ifaces_hash([ifhash])
    function_check_networks_hash([nethash])

    # Not useful the check `meta_options` variable because meta options
    # belong to the code of this puppet module. Not a choice of the user.
    #
    # Check the meta options too.
    #unless meta_options.is_a?(Array) and not meta_options.empty?()
    #  raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
    #        '`meta_options` argument must be a non empty array')
    #end
    #meta_options.each do |value|
    #  unless value.is_a?(String) and not value.empty?()
    #    raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
    #          '`meta_options` argument must be an array of non empty strings')
    #  end
    #end

    # Create the nethash_objects hash.
    # It's better to not change the states of the arguments
    # when it's not necessary.
    nethash_objects = {}
    nethash.each do |network, properties|
      nethash_objects[network] = IPAddr.new(properties['cidr_address'])
    end

    # Update the ifhash.
    ifhash.each do |iface, properties|

      # If there is a CIDR address, it's possible to complete
      # some properties.
      if properties.has_key?('address') and properties['address'].include?('/')
        use_cidr = true
      else
        use_cidr = false
      end

      if use_cidr
        ipaddr_network = IPAddr.new(properties['address'])
        array_address = properties['address'].split('/')
        address = array_address[0]
        bitmask_num = array_address[1]
        ipaddr_netmask = IPAddr.new('255.255.255.255/' + bitmask_num)

        # Update the IP address (without the '/xx').
        properties['address'] = address

        # Add the network if it doesn't exist.
        if not properties.has_key?('network')
          properties['network'] = ipaddr_network.to_s()
        else
          unless properties['network'] == ipaddr_network.to_s()
            raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
                  "`#{iface}` interface has a CIDR address not compatible " +
                  'with the provided `network` property')
          end
        end

        # Add the netmask if it doesn't exist.
        if not properties.has_key?('netmask')
          properties['netmask'] = ipaddr_netmask.to_s()
        else
          unless properties['netmask'] == ipaddr_netmask.to_s()
            raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
                  "`#{iface}` interface has a CIDR address not compatible " +
                  'with the provided `netmask` property')
          end
        end

        # Add the broadcast if it doesn't exist.
        broadcast = ipaddr_netmask.~().|(ipaddr_network).to_s()
        if not properties.has_key?('broadcast')
          properties['broadcast'] = broadcast
        else
          unless  properties['broadcast'] == broadcast
            raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
                  "`#{iface}` interface has a CIDR address not compatible " +
                  'with the provided `broadcast` property')
          end
        end
      end

      # Search for the matching network to make completion in 2 cases:
      # 1. if the "network_name" property is defined.
      # 2. if the "address" property is defined and is a CIDR address.
      has_matching_network = false

      if properties.has_key?('network_name')
        if nethash.has_key?(properties['network_name'])
          if properties.has_key?('address')
            # If the "address" property exits, necessarily the
            # "netmask" property exists too.
            ipnet = IPAddr.new(properties['address'] +
                               '/' + properties['netmask'])
            if not ipnet.eql?(nethash_objects[properties['network_name']])
              raise(Puppet::ParseError, 'complete_ifaces_hash(): the ' +
                    "`#{iface}` interface has a matching network found " +
                    'due to the `network_name` property but the CIDR ' +
                    'addresses are not equal between the interface and ' +
                    'the network')
            end
          end
          has_matching_network = true
          matching_network = properties['network_name']
          default_properties = nethash[matching_network]
        else
          raise(Puppet::ParseError, "complete_ifaces_hash(): the `#{iface}` " +
                'interface has a `network_name` property which does not ' +
                'match with any network.')
        end
      else # There is no "network_name" property.
        if use_cidr
          # The function will fail if there is not a unique matching
          # network.
          matching_network = function_get_network_name([
                              properties['address'],
                              properties['netmask'],
                              nethash,
                             ])
          default_properties = nethash[matching_network]
          has_matching_network = true
        end
      end

      # We can update the properties of the interface if
      # it has a matching network.
      if has_matching_network

        # Update values equal to 'default'.
        properties.each do |name, value|
          if value == '<default>'
            if default_properties.has_key?(name)
              properties[name] = default_properties[name]
            else
              raise(Puppet::ParseError, "complete_ifaces_hash(): the " +
                    "`#{iface}` interface has the `#{name}` property equal " +
                    'to "<default>" but this property is not defined in the ' +
                    "`#{matching_network}` matching network")
            end
          end
        end

        # Add the "network_name" property if it doesn't exist.
        if not properties.has_key?('network_name')
          properties['network_name'] = matching_network
        end

        # Add the meta_options values if defined in the matching network
        # (and not defined in the interface).
        meta_options.each do |meta_option|
          if default_properties.has_key?(meta_option)
            if not properties.has_key?(meta_option)
              properties[meta_option] = default_properties[meta_option]
            end
          end
        end

      end # End of has_matching_network.

    end # End of the "ifhash" loop.

    ifhash

  end
end


