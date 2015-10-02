class samba4::common::params {

  # If realm is "DOMAIN-91.FOO.TLD", workgroup will be "DOMAIN-91".
  $realm        = upcase($domain)
  $workgroup    = regsubst($realm, '^([-A-Z0-9]*)\..*$', '\1')
  $netbios_name = upcase($hostname)

  $conf         = hiera_hash('samba4')
  $ntp_server   = $conf['ntp_server']

  if ($ntp_server == '') {
    fail("you must provide a ntp_server key in the hiera configuration of samba4")
  }

}


