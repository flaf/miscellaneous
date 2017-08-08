Puppet::Functions.create_function(:'monitoring::sorthostsconf') do

  dispatch :sorthostsconf do
    required_param 'Array[Monitoring::HostConf]', :hostsconf
    return_type 'Array[Monitoring::HostConf]'
  end

  def sorthostsconf(hostsconf)

    hostsconf.each do |hostconf|

      templates = hostconf['templates']
      custom_variables = hostconf['custom_variables']
      extra_info = hostconf['extra_info']

      templates.uniq!
      star_tpl = templates.select {|t| t =~ /\*$/}
      if star_tpl.size == 1
        star_tpl = star_tpl[0]
        star_tpl_without_star = star_tpl[0..-2] # the trailing * is removed.
        templates.delete(star_tpl)
        # Maybe the `*` is present without the `*` too. No problem.
        templates.delete(star_tpl_without_star)
        templates.sort! # All templates except the `*` template are sorted.
        hostconf['templates'] = [star_tpl_without_star].concat(templates)
      else
        # We are sure that there is no `*` template.
        templates.sort!
      end

      # custom_variables is sorted by varname.
      custom_variables.sort_by! {|cv| cv['varname']}

      # The value of custom variables will be sorted when
      # it's an array or a hash.
      custom_variables.each_with_index do |customvar, index|
        varname = customvar['varname']
        value = customvar['value']
        if value.is_a?(Array)
          value.uniq!
          value.sort!
        end
        if value.is_a?(Hash)
           hostconf['custom_variables'][index]['value'] = Hash[value.sort]
        end
      end

      if extra_info.key?('check_dns')
        check_dns = extra_info['check_dns']
        hostconf['extra_info']['check_dns'] = Hash[check_dns.sort_by {|desc, v| v['fqdn']}]
      end

      if extra_info.key?('blacklist')
        bl = extra_info['blacklist']
        bl.sort_by! {|rule| rule['description'] }
      end

    end # End of loop on hostsconf.

    hostsconf.sort_by {|a_hostconf| a_hostconf['host_name']}

  end

end


