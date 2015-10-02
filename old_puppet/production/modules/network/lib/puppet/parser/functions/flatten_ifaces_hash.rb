module Puppet::Parser::Functions
  newfunction(:flatten_ifaces_hash, :type => :rvalue, :doc => <<-EOS
Takes one "interfaces" hash as argument and returns a new version
where the array values are flattened. Furthermore, if a value
has this form "@xxxx", it's replaced by the value of the @xxxx
variable.
    EOS
  ) do |args|

    Puppet::Parser::Functions.function('check_ifaces_hash')

    num_args = 1
    unless(args.size == num_args)
      raise(Puppet::ParseError, 'flatten_ifaces_hash(): wrong number of ' +
            "arguments given (#{args.size} instead of #{num_args})")
    end

    ifhash = args[0]
    function_check_ifaces_hash([ifhash])

    def replace_value(value, iface, property)
      value = value.strip()
      if value =~ /^@[a-z0-9_]+$/
        value = lookupvar(value.gsub('@', ''))
      end
        unless value.is_a?(String) and not value.empty?()
          raise(Puppet::ParseError, 'flatten_ifaces_hash(): in the ' +
                "`#{iface}` interface, there is a problem of " +
                "variable substitution in the `#{property}` property")
        end
        return value
    end

    ifhash.each do |iface, properties|
      properties.each do |name, value|

        if value.is_a?(Array)

          value.each_with_index do |v, i|
            v = v.strip()
            if v =~ /^@[a-z0-9_]+$/
              value[i] = lookupvar(v.gsub('@', ''))
              unless value[i].is_a?(String) and not value[i].empty?()
                raise(Puppet::ParseError, 'flatten_ifaces_hash(): in the ' +
                      "`#{iface}` interface, there is a problem of " +
                      "variable substitution in the `#{name}` property")
              end
            end
          end
          properties[name] = value.join(' ')

        else # value is a string.

          value = value.strip()
          if value =~ /^@[a-z0-9_]+$/
            value = lookupvar(value.gsub('@', ''))
            unless value.is_a?(String) and not value.empty?()
              raise(Puppet::ParseError, 'flatten_ifaces_hash(): in the ' +
                    "`#{iface}` interface, there is a problem of " +
                    "variable substitution in the `#{name}` property")
            end
            properties[name] = value
          end

        end

      end # Loop in properties.
    end # Loop in ifhash.

  end
end


