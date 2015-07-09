Puppet::Functions.create_function(:'network::get_matching_network') do

  dispatch :get_matching_network do
    required_param 'Hash[String[1], Data, 1]', :an_interface
    required_param 'Array[Hash[String[1], Data, 3], 1]', :networks
  end

  def get_matching_network(an_interface, networks)

    call_function('::network::check_interface', an_interface)

  end

end


