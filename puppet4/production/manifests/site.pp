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


#$a = ::network::get_matching_network('10.0.2.5/4')
#$b = $::servername
#$c = 'eeee'.::homemade::ljust(10, ' ')
#$d = $::facts['networking']['interfaces']['eth0']['mac']
##notify { 'Test': message => "[${a}]" }
#notify { 'Test1': message => "[${b}]" }
#notify { 'Test2': message => "[${c}]" }
#notify { 'Test3': message => "[${d}]" }

#['trusty', 'jessie'].::homemade::is_supported_distrib($title)


#$vv = { 1 => 'a', 2 => 'b' }
#$v =  {3 => 'c', 1 => 'ZZZZZZZZ'} +$vv
##$v = $vv
#notify { 'Test': message => "[${v}]" }

$i = {
  'eth0' => { 'method'     => 'dhcp',
              'macaddress' => 'rrr',
              'options'    => { "1" => '2', 'address' => '34' },
   }
}

::network::check_interfaces($i)

