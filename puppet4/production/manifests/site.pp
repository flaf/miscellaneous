stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis'] -> Stage['network']
               -> Stage['repository']
               -> Stage['main']

# We assume that the $::role variable is already defined
# by the ENC and must be a non empty string.
if $::role =~ String[1] {
  include "${::role}"
} else {
  fail(regsubst(@(END), '\n', ' ', 'G'))
    Sorry, the node must have a `$role` global variable defined
    and it must be a non empty string.
    |- END
}

#include '::network::interfaces'

$i = { 'name'   => 'eth0',
       'method' => 'dhcp',
     }

$n = [ { 'name'         => 'network-mgt',
         'cidr-address' => '172.31.0.0/16',
         'vlan-id'      => 1000,
       }
     ]

#$s = ::network::get_matching_network($i, $n)

notify { 'Test': message => $s, }

