Puppet::Functions.create_function(:'monitoring::pdbquery2hostsconf') do

  dispatch :pdbquery2hostsconf do
    required_param 'Array[Struct[{ title => String[1], certname => String[1], parameters => Monitoring::CheckPoint }], 1]', :pdbquery
  end

  def pdbquery2hostsconf(pdbquery)

    function_name = 'monitoring::pdbquery2hostsconf'

    hostsconf_hash = {}

    pdbquery.each do |checkpoint_wrapper|

      title = checkpoint_wrapper['title']
      certname = checkpoint_wrapper['certname']
      checkpoint = checkpoint_wrapper['parameters']

      host_name = checkpoint['host_name']
      address = checkpoint['address']                   # can be nil.
      templates = checkpoint['templates']               # can be nil.
      custom_variables = checkpoint['custom_variables'] # can be nil.
      extra_info = checkpoint['extra_info']             # can be nil.
      monitored = checkpoint['monitored']               # can be nil.

      if hostsconf_hash.key?(host_name)

        #############################################
        ### Begin: update of the current hostconf ###
        #############################################

        current_hostconf = hostsconf_hash[host_name]

        ### Handle of "address" ###
        if not address.nil?
          current_address = current_hostconf['address']
          if current_address.nil?
            current_hostconf['address'] = current_address
          else
            if current_address != address
              msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): problem with the checkpoint resource `#{title}`
              |of the host_name `#{host_name}` which has an `address` parameter
              |set to `#{address}` which is different of a value already recorded
              |in another checkpoint resource.
              EOS
              raise(Puppet::ParseError, msg)
            end
          end
        end

        ### Handle of "templates" ###
        if (not templates.nil?) and (not templates.empty?)
          current_templates = current_hostconf['templates']
          if current_templates.nil? or current_templates.empty?
            current_hostconf['templates'] = templates.uniq
          else
            current_hostconf['templates'] = current_templates.concat(templates).uniq
          end
        end

        ### Handle of "custom_variables" ###
        if (not custom_variables.nil?) and (not custom_variables.empty?)
          current_custom_variables = current_hostconf['custom_variables']

          if current_custom_variables.nil? or current_custom_variables.empty?
            current_hostconf['custom_variables'] = custom_variables
          else
            custom_variables.each do |a_variable|
              varname = a_variable['varname']
              value = a_variable['value']

              # Test is a_variable is already present in
              # current_custom_variables ie a variable with
              # the same varname.
              current_variable = nil
              current_index = nil
              current_custom_variables.each_with_index do |e, index|
                if e['varname'] == varname
                  current_variable = e
                  current_index = index
                  break
                end
              end

              if current_variable.nil?
                # a_variable is not already present.
                current_custom_variables << a_variable
              else
                # a_variable is already present in
                # current_custom_variables.
                current_value = current_variable['value']

                if current_value.is_a?(String)
                  raise(Puppet::ParseError, 'Error')
                end

                if current_value.is_a?(Array)
                  if not value.is_a?(Array)
                    raise(Puppet::ParseError, 'Error')
                  end
                  current_custom_variables[current_index]['value'] = current_value.concat(value).uniq
                end

                if current_value.is_a?(Hash)
                  if not value.is_a?(Hash)
                    raise(Puppet::ParseError, 'Error')
                  end
                  current_custom_variables[current_index]['value'] = current_value.merge(value) {|k, v1, v2|
                    raise(Puppet::ParseError, 'Error')
                  }
                end
              end

            end
          end
        end

        ###########################################
        ### End: update of the current hostconf ###
        ###########################################
      else
        # This is the first time that this host_name has a
        # hostconf.
        hostsconf_hash[host_name] = checkpoint
      end

    end # Enf of the loop on pdbquery.

    # TODO: check that "address" is well defined for each host in hostsconf_hash.

    hostsconf_hash.values

  end # End of def.

end # Enf of def



