Puppet::Functions.create_function(:'network::check_networks') do

  dispatch :check_networks do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :networks
  end

  def check_networks(networks)

    function_name  = 'check_networks'
    mandatory_keys = {
                       'cidr-address' => String,
                       'vlan-id'      => Integer,
                     }

    networks.each do |netname, a_network|

      mandatory_keys.each do |key_name, key_type|

        # Check if each mandatory key is present.
        unless a_network.has_key?(key_name) and a_network[key_name].is_a?(key_type)
          msg_mandatory_keys = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{netname}` network hash is not valid.
          |The key `#{key_name}` must exist and its value must have the
          |`#{key_type.to_s}` type.
          EOS
          raise(Puppet::ParseError, msg_mandatory_keys)
        end

      end

      a_network.each do |k, v|

        # Check if each value is not empty.
        if a_network[k].methods.include?(:empty?)
          if a_network[k].empty?
            msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{netname}` network hash is not valid
            |because the value of the key `#{k}` is empty.
            EOS
            raise(Puppet::ParseError, msg_empty_key)
          end
        end

      end

      # Specific check for the CIDR address.
      call_function('::network::check_cidr_address', a_network['cidr-address'])

    end

    true

  end

end


