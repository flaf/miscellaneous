Puppet::Functions.create_function(:'network::get_matching_network') do

  dispatch :get_matching_network do
    required_param 'String[1]', :cidr_address
    #required_param 'Hash[String[1], Hash[String[1], Data, 1] , 1]', :networks
  end

  def get_matching_network(cidr_address)
  #def get_matching_network(cidr_address, networks)

    call_function('::network::_dump_cidr_address', cidr_address).to_s

  end

end


