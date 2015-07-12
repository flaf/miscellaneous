Puppet::Functions.create_function(:'network::get_matching_network') do

  dispatch :get_matching_network do
    required_param 'Hash[String[1], Data, 1]', :an_interface
    required_param 'Array[Hash[String[1], Data, 3], 1]', :networks
  end

  def get_matching_network(an_interface, networks)

    dir = File.expand_path(File.dirname(__FILE__))
    require "#{dir}/ruby/interface"

    call_function('::network::check_interface', an_interface)

    networks.each do |a_network|
      call_function('::network::check_network', a_network)
    end

    iface = { 'name'   => 'eth1',
              'methood' => 'dhcp',
            }

    begin
      i = Interface.new(iface)
    rescue Exception
      raise(Puppet::ParseError, $!)
    end
  end

end


