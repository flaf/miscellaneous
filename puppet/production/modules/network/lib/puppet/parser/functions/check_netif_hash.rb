module Puppet::Parser::Functions
  newfunction(:check_netif_hash, :doc => <<-EOS
...
EOS
  ) do |args|

    unless(args.size == 1)
      raise(Puppet::ParseError, 'check_netif_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of 1)")
    end

    hash = args[0]

    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, 'check_netif_hash(): the argument must be ' +
            'a hash')
    end

    hash.each do |netif, properties|

      unless properties.is_a?(Hash)
        raise(Puppet::ParseError, 'check_netif_hash(): the properties ' +
              "associated with the `#{netif}` network/interface is not a hash")
      end

      properties.each do |name, value|

        unless value.is_a?(String) or value.is_a?(Array)
          raise(Puppet::ParseError, 'check_netif_hash(): the property ' +
                "`#{name}` of the `#{netif}` network/interface is not " +
                'a string or an array')
        end

        if value.is_a?(Array)

          value.each do |elt|

            if elt.is_a?(String)
              next
            else
              raise(Puppet::ParseError, 'check_netif_hash(): the property ' +
                    "`#{name}` of the `#{netif}` network/interface is an " +
                    'array which contains non string value')
            end

          end # End of `value` loop.

        end # End of if.

      end # End of the `properties` loop.

    end # End of the `hash`loop.


  end

end



