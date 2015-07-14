script_dir = File.expand_path(File.dirname(__FILE__))

require 'json'
require "#{script_dir}/interface"

conf = {
        'name'    => 'eth0',
        'method'  => 'dhcp',
        'comment' => 'Blabla blabla',
        'options' => {
                       'key1'    => 'value1',
                       'key2'    => '1234',
                       'address' => '172.31.10.11/20',
                      },
       }

iface = Interface.new(conf)

puts iface.instance_variable_get(:@name)
puts iface.instance_variable_get(:@ip_address)
puts JSON.pretty_generate(iface.instance_variable_get(:@conf))

conf2 = {
         'name'         => 'network-mgt',
         'cidr-address' => '172.31.0.0/20',
         'vlan-id'      => 1001,
         'dns-servers'  => [ 'a' ],
}

network = Network.new(conf2)

puts JSON.pretty_generate(network.instance_variable_get(:@conf))


