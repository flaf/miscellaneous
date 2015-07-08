Puppet::Functions.create_function(:'test::f') do

  dispatch :f do
    required_param 'Integer[0]', :n
    #required_param 'Integer[0, default]', :n
    #required_param 'Integer[0, 13]', :n
  end

  def f(n)
    true
  end

end


