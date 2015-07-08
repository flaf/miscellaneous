Puppet::Functions.create_function(:'test::foo') do

  dispatch :foo do
    param 'Hash', :a_hash
    param 'Array', :an_array
    param 'String', :a_string
  end

  def foo(a_hash, an_array, a_string)

    a_hash['new'] = 'NEW'
    a_hash['a'] = 'BOUM!!!'

    an_array[0] = 'BOUM!!!'
    an_array[3] = 'NEW'

    a_string = 'NEW'

    true
  end

end


