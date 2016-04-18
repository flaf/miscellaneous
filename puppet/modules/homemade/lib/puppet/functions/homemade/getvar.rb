Puppet::Functions.create_function(:'homemade::getvar', Puppet::Functions::InternalFunction) do

  dispatch :getvar do
    scope_param()
    required_param 'Pattern[/^[_a-z0-9:]+$/]', :varname
  end

  def getvar(scope, varname)

    if scope.include?(varname) and (not scope[varname].nil?)
      scope[varname]
    else
      function_name = 'homemade::getvar'
      title = scope['title']
      msg = <<-"EOS".gsub(/\n\s*/, ' ').strip
        in #{title} the variable `#{varname}` retrieved by
        #{function_name}() is undefined which is forbidden.
      EOS
      raise(Puppet::ParseError, msg)
    end

  end

end


