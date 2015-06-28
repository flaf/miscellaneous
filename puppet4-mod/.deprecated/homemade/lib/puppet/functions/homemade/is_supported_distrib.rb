Puppet::Functions.create_function(:'homemade::is_supported_distrib') do

  dispatch :is_supported_distrib do
    required_param 'Array', :supp_distribs
    required_param 'String', :current_distrib
    required_param 'String', :class_name
  end

  def is_supported_distrib(supp_distribs, current_distrib, class_name)

    function_name     = 'homemade::is_supported_distrib'
    supp_distribs_str = supp_distribs.join(', ' )

    unless(supp_distribs.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the first argument must be a non empty
        |array of non empty strings.
        EOS
      call_function(:fail, msg)
    end

    supp_distribs.each do |distrib|
      unless(distrib.is_a?(String) and not distrib.empty?)
        msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
          |#{function_name}(): the first argument must be a non empty
          |array of non empty strings.
          EOS
        call_function(:fail, msg)
      end
    end

    unless(current_distrib.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the second argument must be a non empty
        |string.
        EOS
      call_function(:fail, msg)
    end

    unless(class_name.empty?)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |#{function_name}(): the third argument must be a non empty
        |string.
        EOS
      call_function(:fail, msg)
    end

    unless supp_distribs.include?(current_distrib)
      msg = <<-"EOS".gsub(/^\s*\|/, '').split("\n").join(' ')
        |Sorry, the class #{class_name} has never been tested on
        |#{current_distrib}. Supported distribution(s): #{supp_distribs_str}.
        EOS
      call_function(:fail, msg)
    end

  end

end


