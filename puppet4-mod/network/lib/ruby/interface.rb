require 'ipaddr'

class Interface

  def initialize(conf)

    @conf           = conf
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
            |The `#{@conf.to_s}` interface is not valid
            |because the value of the key `#{key_name}` is empty.
            EOS
          raise(Exception, msg_empty_key)
        end
      end

    end

    # Now, we are sure that the interface has a name.
    @name = @conf['name']

  end

end

class Network

  def initialize(conf)
    @conf         = conf
    @name         = conf['name']
    @cidr_address = conf['cidr-address']
    @vlan_id      = conf['vlan-id']
  end

end


