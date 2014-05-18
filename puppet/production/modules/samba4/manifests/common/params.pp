class samba4::common::params {

  # If realm is "DOMAIN-91.FOO.TLD", workgroup will be "DOMAIN-91".
  $realm        = upcase($domain)
  $workgroup    = regsubst($realm, '^([-A-Z0-9]*)\..*$', '\1')
  $netbios_name = upcase($hostname)

}


