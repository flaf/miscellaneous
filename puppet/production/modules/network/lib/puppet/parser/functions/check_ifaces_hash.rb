module Puppet::Parser::Functions
  newfunction(:check_ifaces_hash, :doc => <<-EOS
Checks if the argument is a valid "interfaces" hash.
    EOS
  ) do |args|

    require 'ipaddr'
    Puppet::Parser::Functions.function('check_netif_hash')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'check_ifaces_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    ifhash = args[0]

    # Test the structure of the ifhash.
    function_check_netif_hash([ifhash])

    ifhash.each do |interface, properties|

      # The "method" property must exist.
      unless properties.has_key?('method')
        raise(Puppet::ParseError, "check_ifaces_hash(): the `#{interface}` " +
              'interface has no `method` property')
      end

      # If the method is "static", the "address" property must exist.
      if properties['method'] == 'static'
        unless properties.has_key?('address')
          raise(Puppet::ParseError, "check_ifaces_hash(): the `#{interface}` " +
                'interface uses the `static` method but has no `address` ' +
                'property')
        end
      end

      # If the "address" property exists, the value must be valid
      # (it can be an IP address or a CIDR address).
      if properties.has_key?('address')
        begin
          tmp = IPAddr.new(properties['address'])
        rescue ArgumentError
          raise(Puppet::ParseError, "check_ifaces_hash(): the `#{interface}` " +
                'interface has a `address` property with a bad syntax')
        end
        # If the address is not a CIDR address, the netmask must be
        # defined.
        if not properties['address'].include?('/')
          unless properties.hash_key?('netmask')
            raise(Puppet::ParseError, 'check_ifaces_hash(): the ' +
                  "`#{interface}` interface has a `address` property but " + 
                  'the `netmask` is not applied')
          end
          begin
            tmp = IPAddr.new(properties['address'] + '/' + properties['netmask'])
          rescue ArgumentError
            raise(Puppet::ParseError, 'check_ifaces_hash(): in the ' +
                  "`#{interface}` interface, `address` and `netmask` " +
                  'properties are invalid')
          end
        end
      end

    end

  end
end


