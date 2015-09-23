function unix_accounts::data {

  # Data lookup in hiera or in the environment.conf.
  $users    = lookup('unix_accounts', Hash[String[1], Data, 1])
  $sshkeys  = lookup('sshkeys', Hash[String[1], String[1], 1])

  $default_stage      = 'basis'
  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    unix_accounts::users                   => $users,
    unix_accounts::sshkeys                 => $sshkeys,
    unix_accounts::stage                   => $default_stage,
    unix_accounts::supported_distributions => $supported_distribs,
  }

}


