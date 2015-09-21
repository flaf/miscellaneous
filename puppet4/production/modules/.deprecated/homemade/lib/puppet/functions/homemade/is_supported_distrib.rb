Puppet::Functions.create_function(:'homemade::ljust') do

  dispatch :ljust do
    required_param 'String[1]', :str
    required_param 'Integer[1]', :column
    required_param 'String[1]', :padstr
  end

  def ljust(str, column, padstr)

    str.ljust(column, padstr)

  end

end


