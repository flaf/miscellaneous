module Puppet::Parser::Functions
  newfunction(:fill_ifhash, :type => :rvalue, :doc => <<-EOS
...
EOS
  ) do |args|

    require 'ipaddr'

    unless(args.size == 1)
      raise(Puppet::ParseError, 'fill_ifhash(): wrong number of ' +
            "arguments given (#{args.size} instead of 1)")
    end

    # Hash which contains the properties of interfaces.
    ifhash = args[0]

    unless ifhash.is_a?(Hash)
      raise(Puppet::ParseError, 'fill_ifhash(): the argument must be a hash')
    end

    ifhash.each do |iface, properties|

      # For each interface, `properties` must be a hash.
      unless properties.is_a?(Hash)
        raise(Puppet::ParseError, 'fill_ifhash(): the properties of ' +
              "the `#{iface}` interface is not a hash")
      end

      # For each interface, the 'method' key must exist.
      unless properties.has_key?('method')
        raise(Puppet::ParseError, "fill_ifhash(): the `#{iface}` interface " +
              'has not `method` property')
      end

      # The values of `properties` must be a string or an array
      # of strings. If the value is an array, we update the value
      # to value.join(' ').
      properties.each do |key, value|
        unless value.is_a?(String) or value.is_a?(Array)
        end

        if value.is_a?(Array)
          value.each do |elt|
            if elt.is_a?(String)
              next
            else
              raise(Puppet::ParseError, 'fill_ifhash(): there is one ' +
                    'interface (at least) where the properties contain ' +
                    'an array with a non string value')
            end
          end
          # properties[key] is a valid array, we can update this value.
          properties[key] = value.join(' ')
        end
      end

      unless properties.has_key?('address') then next end
      unless properties['address'].include?('/') then next end

      array_address = properties['address'].split('/')
      address = array_address[0]
      bitmask_num = array_address[1]

      ipaddr_network = IPAddr.new(properties['address'])
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

    end

    ifhash

  end
end


