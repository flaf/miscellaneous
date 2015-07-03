stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis'] -> Stage['network']
               -> Stage['repository']
               -> Stage['main']

# We assume that the $::role variable is already defined
# by the ENC and must be a non empty string.
if $::role =~ String[1] {
  include $::role
} else {
  fail('Sorry, no `$role` global variable is not defined for this node.')
}

#class {'network::interfaces':
#  interfaces => {
#                  'eth1' => {
#                              'macaddress' => 'ccc',
#                              'method'     => 'static',
#                              'comment'    => 'blabla',
#                              'options' => { 'zbkey1' => 'val1', 'aaakey2' => 'val2' },
#                            },
#                  'eth0' => {
#                              'macaddress' => 'aaa',
#                              'method'     => 'static',
#                              'comment'    => 'blabla',
#                              'options' => { 'bkey1' => 'val1', 'aaakey2' => 'val2' },
#                            },
#                }
#}
#
#
#class { '::test':
#  param1 => 'titi1',
#}

#include '::test'



#$iface = 'eth0'
#notify { 'heu':
#
#  message => getvar("::ipaddress_${iface}"),
#
#}

#::homemade::is_supported_distrib([ 'trusty', 'jessie' ], 'trusty', 'site.pp')


#::homemade::is_supp_distrib([ 'trusTy', 'jessie' ], ${title})


