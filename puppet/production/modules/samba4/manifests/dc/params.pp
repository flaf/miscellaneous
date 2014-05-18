class samba4::dc::params {

  $conf          = hiera_hash('samba4')
  $dns_forwarder = $conf['dns_forwarder']

  if ($dns_forwarder == '') {
    fail("you must provide a dns_fowarder key in the hiera configuration of samba4::dc")
  }

}


