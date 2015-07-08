Puppet::Functions.create_function(:'network::check_interface') do

  # The interface is a hash with this form:
  #
  #    {
  #     'eth0' => {
  #                'method' => 'xxx',
  #                'key1'   => 'val1',
  #                'key2'   => 'val2',
  #                ...
  #               }
  #    }
  #
  dispatch :check_interface_name_as_key do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1, 1]', :an_interface
  end

  # The interface is a hash with this (more simple) form:
  #
  #    {
  #     'name'   => 'eth0',
  #     'method' => 'xxx',
  #     'key1'   => 'val1',
  #     'key2'   => 'val2',
  #     ...
  #    }
  #
  dispatch :check_interface do
    required_param 'Hash[String[1], Data, 2]', :an_interface
  end

  def check_interface_name_as_key(an_interface)

    ifname = an_interface.keys[0]

    # If an_interface[ifname] has already the key 'name', we can enter
    # in a infinite recursion. We have to check it.
    if an_interface[ifname].has_key?('name')
      msg_key_name = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the interface `#{an_interface.to_s}` has
        |already a key `name` which is forbidden with this form of
        |hash interface.
        EOS
      raise(Puppet::ParseError, msg_key_name)
    end

    an_interface[ifname]['name'] = ifname
    call_function('::network::check_interface', an_interface[ifname])

    # Be careful: ruby is strictly pass-by-value for the arguments
    # of a function, but the value of hash variable is a reference
    # so that the value of the hash has changed. To avoid this,
    # we delete the 'name' key added previously.
    an_interface[ifname].delete('name')

  end


  def check_interface(an_interface)

    require 'ipaddr'

    # Don't change the value of the argument.
    an_interface.freeze

    function_name  = 'check_interface'
    mandatory_keys = [ 'name', 'method' ]
    allowed_keys   = {
                      'name'         => String,
                      'method'       => String,
                      'options'      => Hash,
                      'network-name' => String,
                      'comment'      => String,
                      'macaddress'   => String,
                     }

    # Check if the mandatory keys are presents.
    mandatory_keys.each do |key|
      unless an_interface.has_key?(key)
        msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the interface `#{an_interface.to_s}` is not
          |valid because it has no `#{key}` key.
          EOS
        raise(Puppet::ParseError, msg_no_key)
      end
    end

    an_interface.each do |key_name, key_value|

      # Check if each key of an_interface is an allowed key.
      unless allowed_keys.include?(key_name)
        msg_key_not_allowed = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the interface `#{an_interface.to_s}` is
          |not valid because the key `#{key_name}` is not an allowed key.
          |Allowed keys are: #{allowed_keys.keys.join(', ')}.
          EOS
        raise(Puppet::ParseError, msg_key_not_allowed)
      end

      # Now, we are sure that the interface has a name.
      ifname = an_interface['name']

      # Check if each key of an_interface has the correct type.
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

      # Check if an_interface['options'] is a hash of strings/strings
      # for the keys/values.
      if key_name == 'options'

        options = an_interface['options']

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

    end # End of the loop on the keys of an_interface.

    true

  end

end


