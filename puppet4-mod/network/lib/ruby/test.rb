script_dir = File.expand_path(File.dirname(__FILE__))

require 'json'
require "#{script_dir}/interface"

conf = {
        #'network-name' => 'network-mgt',
        'name'    => 'eth0',
        'method'  => 'dhcp',
        'comment' => 'Blabla blabla',
        'options' => {
                       'key1'    => 'value1',
                       'key2'    => '1234',
                       'address' => '172.31.10.34',
                       'netmask' => '255.255.0.0',
                      },
       }

iface = Interface.new(conf)

puts iface.get_name
puts iface.get_ip_address
puts JSON.pretty_generate(iface.get_conf)

conf2 = {
         'name'         => 'network-mgt',
         'cidr-address' => '172.31.10.0/24',
         'vlan-id'      => 1001,
         'dns-servers'  => [ 'a', 'b' ],
}

network = Network.new(conf2)

puts JSON.pretty_generate(network.get_conf)

puts "matching? " + iface.is_matching_network(network).to_s

