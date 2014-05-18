class samba4::member::params {

  $conf  = hiera_hash('samba4')
  $ip_dc = $conf['ip_dc']

  if ($ip_dc == '') {
    fail("you must provide a ip_dc key in the hiera configuration of samba4::member")
  }

}


