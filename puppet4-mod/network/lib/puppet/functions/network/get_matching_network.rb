Puppet::Functions.create_function(:'network::get_matching_network') do

  dispatch :get_matching_network do
    required_param 'String[1]', :cidr_address
    required_param 'Integer[1, default]', :networks
  end

  def :get_matching_network(cidr_address, networks)

    true

  end

end



