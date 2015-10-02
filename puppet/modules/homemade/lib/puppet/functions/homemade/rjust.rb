Puppet::Functions.create_function(:'homemade::rjust') do

  dispatch :rjust do
    required_param 'String[1]', :str
    required_param 'Integer[1, default]', :column
    required_param 'String[1]', :padstr
  end

  def rjust(str, column, padstr)

    str.rjust(column, padstr)

  end

end


