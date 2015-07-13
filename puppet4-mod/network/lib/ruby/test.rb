script_dir = File.expand_path(File.dirname(__FILE__))

require "#{script_dir}/interface"

conf = {
        'name'    => 'eth0',
        'method'  => 'dhcp',
        'options' => { 'key1' => 'value1', 'key2' => 'value2' },
       }

iface = Interface.new(conf)

puts iface.instance_variable_get(@name)


