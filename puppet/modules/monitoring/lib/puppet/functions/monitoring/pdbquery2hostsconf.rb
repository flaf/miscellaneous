Puppet::Functions.create_function(:'monitoring::pdbquery2hostsconf') do

  dispatch :pdbquery2hostsconf do
    required_param 'Monitoring::PdbQuery', :pdbquery
    return_type 'Array[Monitoring::HostConf]'
  end

  def pdbquery2hostsconf(pdbquery)

    function_name = 'monitoring::pdbquery2hostsconf'

    hostsconf_hash = {}

    pdbquery.each do |checkpoint_wrapper|

      title = checkpoint_wrapper['title']
      checkpoint = checkpoint_wrapper['parameters']

      host_name = checkpoint['host_name']
      address = checkpoint['address']                   # can be nil.
      templates = checkpoint['templates']               # can be nil.
      custom_variables = checkpoint['custom_variables'] # can be nil.
      extra_info = checkpoint['extra_info']             # can be nil.
      monitored = checkpoint['monitored']               # can be nil.

      # If the host_name field of a rule in the blacklist is
      # not present, we have to set it to the host_name of
      # the current checkpoint resource. We add ^ and $
      # because it's a regex and we escape the dot
      # character.
      if not extra_info.nil? and not extra_info['blacklist'].nil? and not extra_info['blacklist'].empty?
        extra_info['blacklist'].each do |rule|
          if rule['host_name'].nil?
            rule['host_name'] = '^' + host_name.gsub('.', '\.') + '$'
          end
        end
      end

      # If not nil or empty, the templates array can contain
      # only one `*` template (0 or 1).
      if not templates.nil? and not templates.empty?
        star_tpl = templates.select {|t| t =~ /\*$/}
        if star_tpl.size > 1
          msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): problem with the checkpoint resource `#{title}`
          |of the host_name `#{host_name}` which has a `templates` parameter
          |which contains at least 2 templates with the trailing character `*`:
          |`#{star_tpl}`. This is not allowed, if defined, the `*` template
          |must be unique.
          EOS
          raise(Puppet::ParseError, msg)
        end
      end


      if hostsconf_hash.key?(host_name)

        #############################################
        ### Begin: update of the current hostconf ###
        #############################################

        current_hostconf = hostsconf_hash[host_name]

        ###########################
        ### Handle of "address" ###
        ###########################
        if not address.nil?
          current_address = current_hostconf['address']
          if current_address.nil?
            current_hostconf['address'] = address
          else
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): problem with the checkpoint resource `#{title}`
            |of the host_name `#{host_name}` which has an `address` parameter
            |set to `#{address}` but this parameter is already recorded in a
            |previous checkpoint resource (with the value `#{current_address}`).
            |This is not allowed, the `address` parameter must be set exactly
            |in only one checkpoint resource (for a given host).
            EOS
            raise(Puppet::ParseError, msg)
          end
        end

        #############################
        ### Handle of "templates" ###
        #############################
        if (not templates.nil?) and (not templates.empty?)
          current_templates = current_hostconf['templates']
          if current_templates.nil? or current_templates.empty?
            current_hostconf['templates'] = templates
          else
            star_tpl = templates.select {|t| t =~ /\*$/}
            if star_tpl.size > 0
              # We are sure that the star template is unique.
              star_tpl = star_tpl[0]
              current_star_tpl = current_templates.select {|t| t =~ /\*$/}
              if current_star_tpl.size > 0
                if not current_star_tpl.include?(star_tpl)
                  msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): problem with the checkpoint resource `#{title}`
                  |of the host_name `#{host_name}` and its `templates` parameter.
                  |This parameter set `#{star_tpl}` as `*` template but a previous
                  |checkpoint resource has been already recorded with this `*`
                  |template: `#{current_star_tpl}`. This is not allowed, if defined,
                  |the `*` template must be unique (for a given host).
                  EOS
                  raise(Puppet::ParseError, msg)
                end
              end
            end
            current_hostconf['templates'] = current_templates.concat(templates)
          end
        end

        ####################################
        ### Handle of "custom_variables" ###
        ####################################
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
                # a_variable is not already present, so it's added.
                current_custom_variables << a_variable
              else
                # a_variable is already present in
                # current_custom_variables.
                current_value = current_variable['value']

                # Test if the type of current_value and value are the same.
                if current_value.class != value.class
                  msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): problem with the checkpoint resource
                  |`#{title}` of the host_name `#{host_name}` which has a
                  |custom variable `#{varname}` set to  the value `#{value}`
                  |whose type is `#{value.class}`. This custom variable has
                  |been already recorded in a previous checkpoint resource
                  |with a different type: the type `#{current_value.class}`
                  |(and the value `#{current_value}`). If a custom variable
                  |is updated by an additional checkpoint, its type must
                  |remain exactly the same.
                  EOS
                  raise(Puppet::ParseError, msg)
                end


                if current_value.is_a?(String)
                  msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): problem with the checkpoint resource
                  |`#{title}` of the host_name `#{host_name}` which has a
                  |custom variable `#{varname}` set to the String `#{value}`
                  |but this custom variable has been already recorded in a
                  |previous checkpoint resource with the String value
                  |`#{current_value}`. It's not allowed to update a custom
                  |variable of type String.
                  EOS
                  raise(Puppet::ParseError, msg)
                end

                if current_value.is_a?(Array)
                  current_custom_variables[current_index]['value'] = current_value
                  .concat(value)
                end

                if current_value.is_a?(Hash)
                  current_custom_variables[current_index]['value'] = current_value
                  .merge(value) {|k, v1, v2|
                    msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                    |#{function_name}(): problem with the checkpoint resource
                    |`#{title}` of the host_name `#{host_name}` which has a
                    |custom variable `#{varname}` set to the Hash `#{value}`.
                    |This custom variable has been already recorded in a
                    |previous checkpoint resource with the Hash value
                    |`#{current_value}`. There is a common  key `#{k}` which
                    |is not allowed. When a Hash custom variable is updated,
                    |the value of a key can't not be modified, only new keys
                    |can be added.
                    EOS
                    raise(Puppet::ParseError, msg)
                  }
                end
              end

            end
          end
        end

        ##############################
        ### Handle of "extra_info" ###
        ##############################
        if (not extra_info.nil?) and (not extra_info.empty?)

          current_extra_info = current_hostconf['extra_info']

          if current_extra_info.nil? or current_extra_info.empty?
            current_hostconf['extra_info'] = extra_info
          else

            ################################
            ### Handle of "ipmi_address" ###
            ################################
            if extra_info.key?('ipmi_address')
              if current_extra_info.key?('ipmi_address')
                msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): problem with the checkpoint resource
                |`#{title}` of the host_name `#{host_name}` which has the
                |extra info `ipmi_address` set to the String
                |`#{extra_info['ipmi_address']}`. This extra info has been
                |already recorded in a previous checkpoint resource with the
                |String value `#{current_extra_info['ipmi_address']}`.
                |This is not allowed. The `ipmi_address` extra info can be
                |defined in only one checkpoint resource.
                EOS
                raise(Puppet::ParseError, msg)
              else
                current_extra_info['ipmi_address'] = extra_info['ipmi_address']
              end
            end

            #############################
            ### Handle of "blacklist" ###
            #############################
            if not extra_info['blacklist'].nil? and not extra_info['blacklist'].empty?

              if current_extra_info.key?('blacklist')
                current_extra_info['blacklist'] = current_extra_info['blacklist']
                .concat(extra_info['blacklist'])
              else
                current_extra_info['blacklist'] = extra_info['blacklist']
              end

            end

            #############################
            ### Handle of "check_dns" ###
            #############################
            if not extra_info['check_dns'].nil? and not extra_info['check_dns'].empty?
              if current_extra_info.key?('check_dns')
                current_extra_info['check_dns'] = current_extra_info['check_dns']
                .merge(extra_info['check_dns']) {|desc, oldv, newv|
                  msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                  |#{function_name}(): problem with the checkpoint resource
                  |`#{title}` of the host_name `#{host_name}` which has the
                  |extra info `check_dns` set to the Hash
                  |`#{extra_info['check_dns']}`. The key `#{desc}` has been
                  |already recorded in the `check_dns` extra info of a previous
                  |checkpoint resource with the Hash value
                  |`#{current_extra_info['check_dns']}`. This is not allowed.
                  |The extra info `check_dns` can be merged from different
                  |checkpoint resources but with different keys, ie different
                  |descriptions.
                  EOS
                  raise(Puppet::ParseError, msg)
                }
              else
                current_extra_info['check_dns'] = extra_info['check_dns']
              end
            end

          end
        end

        #############################
        ### Handle of "monitored" ###
        #############################
        if not monitored.nil?
          current_monitored = current_hostconf['monitored']
          if current_monitored.nil?
            current_hostconf['monitored'] = monitored
          else
            msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): problem with the checkpoint resource
            |`#{title}` of the host_name `#{host_name}` which has the
            |`monitored` parameter set to `#{monitored}`. This parameter
            |has been already recorded in a previous checkpoint resource
            |with the value `#{current_monitored}`. This is not allowed,
            |this parameter must be defined in only one checkpoint
            |resource (for a given host).
            EOS
            raise(Puppet::ParseError, msg)
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

    ################################
    ### Some cleaning and checks ###
    ################################
    hostsconf_hash.each do |host_name, checkpoint|

      if checkpoint['address'].nil?
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): problem with the host `#{host_name}`
        |after collecting all the checkpoint resources: the `address`
        |parameter of this host has never been set in any checkpoint
        |resource. This is not allowed, a host must have an address.
        EOS
        raise(Puppet::ParseError, msg)
      end

      if checkpoint['templates'].nil? or checkpoint['templates'].empty?
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): problem with the host `#{host_name}`
        |after collecting all the checkpoint resources: the `templates`
        |parameter of this host has never been set in any checkpoint
        |resource (or maybe set to an empty array). This is not allowed,
        |a host must have at least one template.
        EOS
        raise(Puppet::ParseError, msg)
      end

      star_tpl = checkpoint['templates'].select {|t| t =~ /\*$/}
      if star_tpl.size > 1
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): problem with the host `#{host_name}`
        |after collecting all the checkpoint resources: the `templates`
        |parameter of this host has at least 2 `*` templates
        |`#{star_tpl}`. This is not allowed, if defined, the `*`
        |must be unique.
        EOS
        raise(Puppet::ParseError, msg)
      end

      if checkpoint['custom_variables'].nil?
        checkpoint['custom_variables'] = []
      end

      if checkpoint['extra_info'].nil?
        checkpoint['extra_info'] = {}
      end

      if checkpoint['monitored'].nil?
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): problem with the host `#{host_name}`
        |after collecting all the checkpoint resources: the `monitored`
        |parameter of this host has never been set in any checkpoint
        |resource. This is not allowed, a host must have this parameter
        |defined.
        EOS
        raise(Puppet::ParseError, msg)
      end

    end

    hostsconf_hash.values

  end # End of def.

end


