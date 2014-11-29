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

      if not properties.has_key?('address') then next end
      if not properties['address'].include?('/') then next end

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


