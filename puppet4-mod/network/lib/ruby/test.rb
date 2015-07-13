script_dir = File.expand_path(File.dirname(__FILE__))

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


