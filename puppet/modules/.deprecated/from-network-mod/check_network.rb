Puppet::Functions.create_function(:'network::check_network') do

  # The network is a hash with this form:
  #
  #    {
  #     'network-mgt' => {
  #                       'cidr-address' => '172.31.0.0/16',
  #                       'vlan-id'      => 1000,
  #                       ...
  #                      }
  #    }
  #
  dispatch :check_network_name_as_key do
    required_param 'Hash[String[1], Hash[String[1], Data, 2], 1, 1]', :a_network
  end

  # The network is a hash with this (more simple) form:
  #
  #    {
  #     'name'         => 'network-mgt',
  #     'cidr-address' => '172.31.0.0/16',
  #     'vlan-id'      => 1000,
  #     ...
  #    }
  #
  dispatch :check_network do
    required_param 'Hash[String[1], Data, 3]', :a_network
  end

  def check_network_name_as_key(a_network)

    netname = a_network.keys[0]

    # a_network[netname] must not have already the key 'name'.
    if a_network[netname].has_key?('name')
      msg_key_name = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the network `#{a_network.to_s}` has
        |already a key `name` which is forbidden with this form of
        |hash network.
        EOS
      raise(Puppet::ParseError, msg_key_name)
    end

    a_network[netname]['name'] = netname
    call_function('::network::check_network', a_network[netname])

    # Be careful: ruby is strictly pass-by-value for the arguments
    # of a function, but the value of a hash variable is a reference
    # so that the value of the hash can be changed. To avoid this,
    # we delete the 'name' key added previously.
    a_network[netname].delete('name')

  end


  def check_network(a_network)

    function_name  = 'check_network'
    mandatory_keys = {
                       'name'         => String,
                       'cidr-address' => String,
                       'vlan-id'      => Integer,
                     }

    mandatory_keys.each do |key_name, key_type|

      # Check if each mandatory key is present with the good type..
      unless a_network.has_key?(key_name) and a_network[key_name].is_a?(key_type)
        msg_mandatory_keys = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the `#{a_network.to_s}` network hash is not valid.
        |The key `#{key_name}` must exist and its value must have the
        |`#{key_type.to_s}` type.
        EOS
        raise(Puppet::ParseError, msg_mandatory_keys)
      end

    end

    # Now, we are sure that a_network has a name.
    netname = a_network['name']

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

    true

  end

end


