Puppet::Functions.create_function(:'homemade::getvarrb', Puppet::Functions::InternalFunction) do

  dispatch :getvarrb do
    scope_param()
    required_param 'Pattern[/^[_a-z0-9:]+$/]', :varname
  end

  def getvarrb(scope, varname)

    if scope.include?(varname) and (not scope[varname].nil?)
      scope[varname]
    else
      title = scope['title']
      msg = <<-"EOS".gsub(/\n\s*/, ' ').strip
        in #{title} the variable `#{varname}` retrieved by
        homemade::getvarrb() is undefined which is forbidden.
      EOS
      raise(Puppet::ParseError, msg)
    end

  end

end


