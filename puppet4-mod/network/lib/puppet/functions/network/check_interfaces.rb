Puppet::Functions.create_function(:'network::check_interfaces') do

  dispatch :check_interfaces do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :interfaces
  end

  def check_interfaces(interfaces)

    require 'ipaddr'

    function_name  = 'check_interfaces'
    mandatory_keys = [ 'method' ]
    allowed_keys   = {
                      'method'       => String,
                      'options'      => Hash,
                      'network-name' => String,
                      'comment'      => String,
                      'macaddress'   => String,
                     }

    interfaces.each do |ifname, a_interface|

      # Check if the mandatory keys are presents.
      mandatory_keys.each do |key|
        unless a_interface.has_key?(key)
          msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the interface `#{ifname}` is not valid
            |because it has no `#{key}` key.
            EOS
          raise(Puppet::ParseError, msg_no_key)
        end
      end

      a_interface.each do |key_name, key_value|

        # Check if each key of a_interface is an allowed key.
        unless allowed_keys.include?(key_name)
          msg_key_not_allowed = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the interface `#{ifname}` is not
            |valid because the key `#{key_name}` is not an allowed key.
            | Allowed keys are: #{allowed_keys.keys.join(', ')}.
            EOS
          raise(Puppet::ParseError, msg_key_not_allowed)
        end

        # Check if each key of a_interface has the correct type.
        unless key_value.is_a?(allowed_keys[key_name])
          msg_wrong_type = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the interface `#{ifname}` is not valid
            |because the type of the key `#{key_name}` is wrong. The
            |type is `#{key_value.class.to_s}` but must be
            |`#{allowed_keys[key_name].to_s}`.
            EOS
          raise(Puppet::ParseError, msg_wrong_type)
        end

        # Check if each key has no empty value.
        if key_value.methods.include?(:empty?)
          if key_value.empty?
            msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{ifname}` interface is not valid
              |because the value of the key `#{key_name}` is empty.
              EOS
            raise(Puppet::ParseError, msg_empty_key)
          end
        end

        # Check if a_interface['options'] is a hash of strings/strings
        # for the keys/values.
        if key_name == 'options'

          options = a_interface['options']

          options.each do |k, v|
            unless k.is_a?(String) and v.is_a?(String) and \
                   (not k.empty?) and (not v.empty?)
              msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): the `#{ifname}` interface is not valid
                |because the hash `options` must be a hash of non empty strings
                |for the keys and the values.
                EOS
              raise(Puppet::ParseError, msg_options_error)
            end

            if k == 'address'
              if v =~ Regexp.new('/')
                msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): the `#{ifname}` interface is not valid
                  |because the `address` option contains "/". The option must
                  |be a real IP address, not a CIDR address.
                  EOS
                raise(Puppet::ParseError, msg_bad_address)
              else
                begin
                  ip_address = IPAddr.new(v)
                rescue ArgumentError
                  msg_bad_address2 = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                    |#{function_name}(): the `#{ifname}` interface is not valid
                    |because the `address` option doesn't contain a valid
                    |IP address.
                    EOS
                  raise(Puppet::ParseError, msg_bad_address2)
                end
              end
            end
          end # End of the handle of options['address'].

        end # End of the handle of the specific "options" key.

      end # End of the loop on the keys of a_interface.

    end # End of the loop on the interfaces.

    true

  end

end


