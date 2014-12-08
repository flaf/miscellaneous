module Puppet::Parser::Functions
  newfunction(:check_networks_hash, :doc => <<-EOS
Checks if the argument is a valid "networks" hash.
    EOS
  ) do |args|

    require 'ipaddr'
    Puppet::Parser::Functions.function('check_netif_hash')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'check_networks_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    nethash = args[0]

    # Test the structure of the nethash.
    function_check_netif_hash([nethash])

    # Test if the "cidr_address" key is present for each network
    # and if its value is correct.
    nethash.each do |network, properties|

      unless properties.has_key?('cidr_address')
        raise(Puppet::ParseError, "check_networks_hash(): the `#{network}` " +
              'network has no `cidr_address` property')
      end

      unless  properties['cidr_address'].include?('/')
        raise(Puppet::ParseError, "check_networks_hash(): the `#{network}` " +
              'network has a `cidr_address` property which does not contain '+
              'the "/" character')
      end

      begin
        IPAddr.new(properties['cidr_address'])
      rescue ArgumentError
        raise(Puppet::ParseError, "check_networks_hash(): the `#{network}` " +
              'network has a `cidr_address` property with a bad syntax')
      end

    end

  end
end


