Puppet::Functions.create_function(:'test::data') do

  def data()
    # Return a hash with parameter name to value mapping
    {
      'test::param1' => 'default value for param1 in class test',
      'test::param2' => call_function( 'getvar', '::test::t1' ),
      #'test::param2' => call_function( 'homemade::myfunction', 'param2', 'aa' ),
      #'test::param2' => 123456,
    }
  end

end

#function test::data {
#
#  {
#    'test::param1' => 'default value for param1 in class test',
#    #'test::param2' => function_hiera(['param2']),
#    'test::param2' => '123456',
#  }
#
#}


