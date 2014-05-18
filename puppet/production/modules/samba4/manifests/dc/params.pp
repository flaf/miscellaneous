class samba4::dc::params {

  $realm         = upcase($domain)
  # If realm is "AAA-91.BBB.CCC", workgroup will be "AAA-91".
  $workgroup     = regsubst($realm, '^([-A-Z0-9]*)\..*$', '\1')

  $conf          = hiera_hash('samba4')
  $dns_forwarder = $conf['dns_forwarder']

  if ($dns_forwarder == '') {
    fail("you must provide a dns_fowarder key in the hiera configuration of samba4")
  }

}


