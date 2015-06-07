Puppet::Functions.create_function(:'homemade::myfunction') do

  dispatch :myfunction do
    param 'String', :str1
    param 'String', :str2
  end

  def myfunction(str1, str2)
    "#{str1} #{str2}"
  end

end


