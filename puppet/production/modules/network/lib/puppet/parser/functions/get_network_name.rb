module Puppet::Parser::Functions
  newfunction(:get_network_name, :type => :rvalue, :doc => <<-EOS
This function takes 3 arguments:
  - an IP string;
  - a netmask string;
  - a "networks" hash.
and it returns the name of the network in the "networks" hash which
matches with the IP an the netmask. If the function doesn't found
a matching network or if there are several matching networks, it
raises an error.
    EOS
  ) do |args|

    require 'ipaddr'
    Puppet::Parser::Functions.function('check_networks_hash')

    num_args = 3
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'get_network_name(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    address = args[0]
    netmask = args[1]
    nethash = args[2]

    unless address.is_a?(String) and not address.empty?()
      raise(Puppet::ParseError, 'get_network_name(): the first argument ' +
            '(the IP address) must be a non empty string')
    end
    unless netmask.is_a?(String) and not netmask.empty?()
      raise(Puppet::ParseError, 'get_network_name(): the second argument ' +
            '(the netmask) must be a non empty string')
    end

    # Test nethash.
    function_check_networks_hash([nethash])

    begin
      network_address = IPAddr.new(address + '/' + netmask)
    rescue ArgumentError
      raise(Puppet::ParseError, "get_network_name(): the `#{address}` " +
            "address and the `#{netmask}` netmask don't give a valid " +
            'CIDR address')
    end

    # Search for the matching network.
    matching_networks = []

    nethash.each do |network, properties|
      a_network_address = IPAddr.new(properties['cidr_address'])
      if network_address.eql?(a_network_address)
        matching_networks.push(network)
      end
    end

    n = matching_networks.length
    if n == 0
      raise(Puppet::ParseError, "get_network_name(): with the `#{address}` " +
            "address and the `#{netmask}` netmask, no matching network has " +
            'been found')
    end

    if n > 1
      raise(Puppet::ParseError, "get_network_name(): with the `#{address}` " +
            "address and the `#{netmask}` netmask, several matching " +
            'networks have been found')
    end

    # Return the name of the uniq matching network.
    matching_networks[0]

  end
end


