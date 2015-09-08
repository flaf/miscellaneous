Puppet::Functions.create_function(:'network::check_inventory_networks') do

  # Check the structure of the inventory_networks parameter
  # as described in the documentation of this module.
  dispatch :check_inventory_networks do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :inventory_networks
  end

  def check_inventory_networks(inventory_networks)

    function_name = 'check_inventory_networks'

    mandatory_keys = [ 'comment',
                       'vlan_id',
                       'vlan_name',
                       'cidr_address',
                     ]

    inventory_networks.each do |netname, params|
      mandatory_keys.each do |mkey|
        unless params.has_key?(mkey)
          msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{netname}` network in
            |the inventory networks is not valid because the
            |mandatory key `#{mkey}` is absent.
            EOS
          raise(Puppet::ParseError, msg)
        end
        if mkey == 'comment'
          unless call_function('::homemade::is_clean_arrayofstr', params[mkey])
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{netname}` network in
              |the inventory networks is not valid because the
              |value of the `#{mkey}` key is not a non-empty
              |array of non-empty strings.
              EOS
            raise(Puppet::ParseError, msg)
          end
        else
          unless params[mkey].is_a?(String) and not params[mkey].empty?
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{netname}` network in
              |the inventory networks is not valid because the
              |value of the `#{mkey}` key is not a non-empty
              |strings.
              EOS
            raise(Puppet::ParseError, msg)
          end
          if mkey == 'cidr_address'
            # The function will raise an exception if the CIDR address
            # is not valid.
            call_function('::network::dump_cidr', params[mkey])
          end
        end
      end
    end

    # If no error, return true.
    true

  end

end


