require 'ipaddr'

class Interface

  def initialize(conf)

    @mandatory_keys = [
                       'name',
                       'method',
                      ]
    @allowed_keys   = {
                       'name'         => String,
                       'method'       => String,
                       'options'      => Hash,
                       'network-name' => String,
                       'comment'      => String,
                       'macaddress'   => String,
                      }
    @conf           = conf

    # Check if the mandatory keys are presents.
    @mandatory_keys.each do |key|
      unless @conf.has_key?(key)
        msg_no_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid because it
          |has no `#{key}` key.
          EOS
        raise(Exception, msg_no_key)
      end
    end

    # Some checkings...
    @conf.each do |key_name, key_value|

      # Check if each key of @conf is an allowed key.
      unless @allowed_keys.include?(key_name)
        msg_key_not_allowed = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid because the
          |key `#{key_name}` is not an allowed key.
          |Allowed keys are: #{@allowed_keys.keys.join(', ')}.
          EOS
        raise(Exception, msg_key_not_allowed)
      end

      # Check if each key of @conf has the correct type.
      unless key_value.is_a?(@allowed_keys[key_name])
        msg_wrong_type = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The interface `#{@conf.to_s}` is not valid
          |because the type of the key `#{key_name}` is wrong. The
          |type is `#{key_value.class.to_s}` but must be
          |`#{@allowed_keys[key_name].to_s}`.
          EOS
        raise(Exception, msg_wrong_type)
      end

      # Check if each key has no empty value.
      if key_value.methods.include?(:empty?)
        if key_value.empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |The interface `#{@conf.to_s}` not valid because
            |the value of the key `#{key_name}` is empty.
            EOS
          raise(Exception, msg_empty_key)
        end
      end

      if key_name == 'options'

        options = @conf['options']
        options.each do |k, v|

          # Check if @conf['options'] is a hash of strings for
          # the keys and the values.
          unless k.is_a?(String) and v.is_a?(String) and \
                 (not k.empty?) and (not v.empty?)
            msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |The interface `#{@conf.to_s}` is not valid because
              |the hash `options` must be a hash of non empty strings
              |for the keys and the values.
              EOS
            raise(Exception, msg_options_error)
          end

          # Check the address.
          if k == 'address'
            begin
              @ip_address = IPAddr.new(v)
            rescue ArgumentError
              msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |The interface `#{@conf.to_s}` is not valid because
                |the `address` option doesn't contain a valid IP
                |address or a CIDR address.
                EOS
              raise(Exception, msg_bad_address)
            end
          end

        end # End of the loop on the keys of @conf['options'].

      end # End of the handle of the specific 'options' key.

    end # End of the loop on the keys of @conf.

    # Now, we are sure that the interface has a name.
    @name = @conf['name']

  end


  def is_matching_network(network)

    if @conf.has_key?('network-name')
    end

  end


end

class Network

  def initialize(conf)

    @mandatory_keys = {
                       'name'         => String,
                       'cidr-address' => String,
                       'vlan-id'      => Integer,
                      }
    @conf           = conf

    # Check if each mandatory key is present with the correct type.
    @mandatory_keys.each do |key_name, key_type|
      unless @conf.has_key?(key_name) and @conf[key_name].is_a?(key_type)
        msg_mandatory_keys = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |The network `#{@conf.to_s}` is not valid. The key
        |`#{key_name}` must exist and its value must have the
        |`#{key_type.to_s}` type.
        EOS
        raise(Exception, msg_mandatory_keys)
      end
    end

    # Check if each value is not empty.
    @conf.each do |k, v|
      if @conf[k].methods.include?(:empty?)
        if @conf[k].empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |The network `#{@conf.to_s}` is not valid
          |because the value of the key `#{k}` is empty.
          EOS
          raise(Exception, msg_empty_key)
        end
      end
    end

    @name         = @conf['name']
    @cidr_address = @conf['cidr-address']
    @vlan_id      = @conf['vlan-id']

    msg_bad_address = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
      |The network `#{@conf.to_s}` is not valid because
      |the `cidr-address` key doesn't contain a valid CIDR
      |address.
      EOS

    unless @cidr_address =~ Regexp.new('/[0-9]+$')
      raise(Exception, msg_bad_address)
    end

    begin
      @ip_address = IPAddr.new(@cidr_address)
    rescue ArgumentError
      raise(Exception, msg_bad_address)
    end

  end

end


