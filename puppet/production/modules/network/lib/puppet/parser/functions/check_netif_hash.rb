#
# == Test
#
# Blabla.
#
module Puppet::Parser::Functions
  newfunction(:check_netif_hash, :doc => <<-EOS
Checks if the argument is a hash with this form:

  {
    "key1" => {
                "key1_a" => "aaa",
                "key1_b" => [ "bbb", "ccc" ],
              },
    "key2" => {
                "key2_a" => [ "ddd", "eee", "fff" ],
                "key2_b" => "ggg",
                "key2_c" => "hhh",
              },
  }

* The argument is a non empty hash.
* Each key of this hash is a non empty string.
* Each value of this hash is a non empty hash (a sub-hash).
* Each key of the sub-hashes is a non empty string.
* Each value of the sub-hashes is a non empty string or an
  array of non empty strings.

If one (at least) of these conditions are not respected, the
function raises an error.
    EOS
  ) do |args|

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'check_netif_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    hash = args[0]

    unless hash.is_a?(Hash) and not hash.empty?()
      raise(Puppet::ParseError, 'check_netif_hash(): the argument must be ' +
            'a non empty hash')
    end

    hash.each do |netif, properties|

      unless netif.is_a?(String) and not netif.empty?()
        raise(Puppet::ParseError, 'check_netif_hash(): the hash ' +
              "has a key which is not a non empty string")
      end

      unless properties.is_a?(Hash) and not properties.empty?()
        raise(Puppet::ParseError, 'check_netif_hash(): the properties ' +
              "associated with the `#{netif}` network/interface is not a " +
              'non empty hash')
      end

      properties.each do |name, value|

        unless name.is_a?(String) and not name.empty?()
          raise(Puppet::ParseError, 'check_netif_hash(): the properties ' +
                "of the `#{netif}` network/interface is a hash with a key " +
                'which is not a non empty string')
        end

        if value.is_a?(String)
          unless not value.empty?()
            raise(Puppet::ParseError, 'check_netif_hash(): the value of the ' +
                  "`#{name}` property in the `#{netif}` network/interface " +
                  'must be a non empty string')
          end
        elsif value.is_a?(Array) and not value.empty?()
          value.each do |elt|
            if elt.is_a?(String) and not elt.empty?() then next end
            raise(Puppet::ParseError, 'check_netif_hash(): the value of ' +
                  " the `#{name}` property in the `#{netif}` " +
                  "network/interface is not an array of non empty strings")
          end
        else
          raise(Puppet::ParseError, 'check_netif_hash(): the value of the ' +
                "`#{name}` property in the `#{netif}` network/interface " +
                'must be only a non empty string or a non empty array of ' +
                'non empty strings')
        end

      end # End of the `properties` loop.

    end # End of the `hash`loop.


  end

end


