Puppet::Functions.create_function(:'network::check_interfaces') do

  # Check the structure of the interfaces parameter
  # as described in the documentation of this module.
  dispatch :check_interfaces do
    required_param 'Hash[String[1], Hash[String[1], Data, 1], 1]', :interfaces
  end

  def check_interfaces(interfaces)

    function_name = 'check_interfaces'

    # Allowed keys for a given interface.
    allowed_keys = [ 'in_networks', # allowed for the `interfaces` key.
                     'routes',
                     'macaddress',
                     'comment',
                     'inet',
                     'inet6',
                   ]

    # Allowed keys for a inet or inet6 hash.
    inet_allowed_keys = [ 'method',
                          'options',
                        ]

    interfaces.each do |ifname, settings|

      # settings must be a hash.
      unless settings.is_a?(Hash)
        msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{ifname}` interface is not valid
          |because its value is not a hash.
          EOS
        raise(Puppet::ParseError, msg_options_error)
      end

      # In settings, there is at least the key `inet` and/or `inet6`.
      unless settings.has_key?('inet') or settings.has_key?('inet6')
        msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the `#{ifname}` interface is not valid
          |because its hash value has neither the `inet` key nor the
          |`inet6` key (at least one of them is required).
          EOS
        raise(Puppet::ParseError, msg_options_error)
      end

      # Each param in settings must be an allowed key.
      settings.each do |param, value|
        unless allowed_keys.include?(param)
          msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{ifname}` interface is not valid
            |because its hash value has the `#{param}` key which is not
            |a allowed key.
            EOS
          raise(Puppet::ParseError, msg_options_error)
        end
      end

      # The "on_networks" key must be mapped to a non-empty array of
      # non-empty strings. It's the same for the "comment" key and
      # the "routes" key.
      [ 'on_networks', 'comment', 'routes' ].each do |e|
        if settings.has_key?(e)
          # TODO: PUP-5209
          #unless call_function('::homemade::is_clean_arrayofstr', settings[e])
          unless call_function('::network::is_clean_arrayofstr', settings[e])
            msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{ifname}` interface is not valid
              |because its hash value has the `#{e}` key which is
              |not mapped to a non-emtpy array of non-empty strings.
              EOS
            raise(Puppet::ParseError, msg_options_error)
          end
        end
      end

      # The "macaddress" key must be mapped to a non-empty string.
      if settings.has_key?('macaddress')
        unless settings['macaddress'].is_a?(String) and \
               not settings['macaddress'].empty?
          msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
            |#{function_name}(): the `#{ifname}` interface is not valid
            |because its hash value has the `macaddress` key which is
            |not mapped to a non-emtpy string.
            EOS
          raise(Puppet::ParseError, msg_options_error)
        end
      end

      # The "inet" and "inet6" keys must be mapped to a hash
      # where the "method" key is mandatory and the "options"
      # key is optional..
      [ 'inet', 'inet6' ].each do |family|
        if settings.has_key?(family)
          unless settings[family].is_a?(Hash)             and \
                 settings[family].has_key?('method')      and \
                 settings[family]['method'].is_a?(String) and \
                 not settings[family]['method'].empty?
            msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
              |#{function_name}(): the `#{ifname}` interface is not valid
              |because its `#{family}` configuration is not a hash with
              |the `method` key (as a non-empty string).
              EOS
            raise(Puppet::ParseError, msg_options_error)
          end
          settings[family].each do |k, v|
            unless inet_allowed_keys.include?(k)
              msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): the `#{ifname}` interface is not valid
                |because in its `#{family}` configuration the key `#{k}`
                |in not a allowed key.
                EOS
              raise(Puppet::ParseError, msg_options_error)
            end
          end
          # TODO: PUP-5209
          #if settings[family].has_key?('options') and \
          #  unless call_function("::homemade::is_clean_hashofstr", settings[family]['options'])
          if settings[family].has_key?('options') and \
            unless call_function("::network::is_clean_hashofstr", settings[family]['options'])
              msg_options_error = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
                |#{function_name}(): the `#{ifname}` interface is not valid
                |because `options` in its `#{family}` configuration is not
                |a non-empty hash of non-empty strings.
                EOS
              raise(Puppet::ParseError, msg_options_error)
            end
          end
        end
      end

    end # End of loop on interfaces.

    # If no error, return true.
    true

  end # End of the function..

end


