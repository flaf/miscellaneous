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
          # TODO: PUP-5209
          #unless call_function('::homemade::is_clean_arrayofstr', params[mkey])
          unless call_function('::network::is_clean_arrayofstr', params[mkey])
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

      end # Loop in mandatory_keys.

      # Now, we check the "routes" entry which is optional.
      # Its value must have this form:
      #
      # routes = {
      #   'route-name1' => { 'to' => 'a-CIDR-address', 'via' => 'an-address' },
      #   'route-name2' => { 'to' => 'a-CIDR-address', 'via' => 'an-address' },
      #   ...
      # }
      if params.has_key?('routes')
        routes = params['routes']
        unless routes.is_a?(Hash)
          msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{netname}` network in
            |the inventory networks is not valid because the
            |value of the `routes` key is not a hash.
            EOS
          raise(Puppet::ParseError, msg)
        end

      end



    end # Loop in inventory_networks.

    # If no error, return true.
    true

  end

end


