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


$dtc                = 'vty'
$inventory_networks = hiera('inventory_networks')
$ipv4_networks      = $::inventory_networks['ipv4']
$ipv6_networks      = $::inventory_networks['ipv6']
$network_conf       = hiera('network')
$interfaces_conf    = $::network_conf

#notify { 'Test': message => "---${::interfaces_conf}---", }


#$a = $inventory_networks['ipv6']
#
#if is_hash($a) {
#  notify { 'Test_hash': message => "Is it a hash? Yes!", }
#} else {
#  notify { 'Test_hash': message => "Is it a hash? No!", }
#}


#$v = lookup('titi')

#notify { 'Test-lookup': message => "---${v}---", }

$a = { 'a' => 1, 'b' => 2, 'd' => 'zut' }
$b = { 'a' => 777, 'b' => 888 }
$c = { 'a' => 'hihi', 'c' => 'pouet', }

$r = reduce([$a, $b, $c]) |$m, $e| { $m + $e }
#notify { 'hash-sum': message => "---${r}---", }


#$f = ::network::test('zzzzzzzzzz')
#notify { 'function': message => "---${f}---", }


#notify { 'function': message => "---${::datacenter}---", }


$v = hiera('key1')
$e = $v[0]

notify { 'function': message => "---${e}---", }

