Puppet::Functions.create_function(:'network::check_network') do

  dispatch :check_network do
    required_param 'Hash[String[1], Data, 1]', :a_network
  end

  def check_network(a_network)

    function_name  = 'check_network'
    mandatory_keys = {
                       'name'         => String,
                       'cidr-address' => String,
                       'vlan-id'      => Integer,
                     }

    mandatory_keys.each do |key_name, key_type|

      unless a_network.has_key?(key_name) and a_network[key_name].is_a?(key_type)
        msg_mandatory_keys = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the `#{a_network.to_s}` network hash
        |is not valid. The key `#{key_name}` must exist and its value
        |must be a `#{key_type.to_s}` data.
        EOS
        raise(Puppet::ParseError, msg_mandatory_keys)
      end

      if a_network[key_name].methods.include?(:empty?)
        if a_network[key_name].empty?
          msg_empty_key = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{a_network.to_s}` network hash
          |is not valid because the value of the key `#{key_name}` is
          |empty.
          EOS
          raise(Puppet::ParseError, msg_empty_key)
        end
      end

    end

    # Specific check for the CIDR address.
    call_function('::network::check_cidr_address', a_network['cidr-address'])

    true

  end

end


