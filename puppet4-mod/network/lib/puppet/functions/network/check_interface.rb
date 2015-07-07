Puppet::Functions.create_function(:'network::check_interface') do

  dispatch :check_interface do
    required_param 'Hash[String[1], Data, 1]', :a_interface
  end

  def check_interface(a_interface)

    require 'ipaddr'

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
      unless a_interface.has_key?(key)
        msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the interface `#{a_interface.to_s}`
          |is not valid because it has no `#{key}` key.
          EOS
        raise(Puppet::ParseError, msg_no_key)
      end
    end

    a_interface.each do |key_name, key_value|

      # Check if each key of a_interface is a allowed_key.
      unless allowed_keys.include?(key_name)
        msg_key_not_allowed = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the interface `#{a_interface.to_s}`
          |is not valid because the key `#{key_name}` is not a allowed key.
          EOS
        raise(Puppet::ParseError, msg_key_not_allowed)
      end

      # Check if each key of a_interface has the correct type.
      unless key_value.is_a?(allowed_keys[key_name])
        msg_wrong_type = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the interface `#{a_interface.to_s}`
          |is not valid because the key `#{key_name}` is not
          |a #{key_type.to_s}.
          EOS
        raise(Puppet::ParseError, msg_wrong_type)
      end

      # Check if each key has no empty value.
      if key_value.methods.include?(:empty?)
        if key_value.empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{a_interface['name']}` interface
            |is not valid because the value of the key `#{key_name}` is
            |empty.
            EOS
          raise(Puppet::ParseError, msg_empty_key)
        end
      end

      # Check if a_interface['options'] is a hash of strings
      # for the keys and strings for the values.
      if key_name == 'options'
        options = a_interface['options']
        options.each do |k, v|
          unless k.is_a?(String) and v.is_a?(String) and \
                 (not k.empty?) and (not v.empty?)
            msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{a_interface['name']}` interface
              |is not valid because the `options` hash must be a hash of non
              |empty string (for the keys and the values)..
              EOS
            raise(Puppet::ParseError, msg_options_error)
          end
          if k == 'address'
            if v =~ Regexp.new('/')
              msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): the `#{a_interface['name']}` interface
                |is not valid because the `address` option contains "/".
                EOS
              raise(Puppet::ParseError, msg_bad_address)
            else
              begin
                ip_address = IPAddr.new(v)
              rescue ArgumentError
                msg_bad_address2 = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): the `#{a_interface['name']}` interface
                  |is not valid because the `address` option doesn't contain
                  |a valid address.
                  EOS
                raise(Puppet::ParseError, msg_cidr_not_valid)
              end
            end
          end
        end
      end
    end

    true

  end

end


:
