function unix_accounts::data {

  # Data lookup in hiera or in the environment.conf.
  $users            = lookup('unix_accounts', Hash[String[1], Data, 1])
  $ssh_public_keys  = lookup('ssh_public_keys', Hash[String[1], String[1], 1])
  $fqdn_in_prompt   = false

  $default_stage      = 'basis'
  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    unix_accounts::users                   => $users,
    unix_accounts::ssh_public_keys         => $ssh_public_keys,
    unix_accounts::fqdn_in_prompt          => $fqdn_in_prompt,
    unix_accounts::stage                   => $default_stage,
    unix_accounts::supported_distributions => $supported_distribs,
  }

}


