function unix_accounts::data {

  # Data lookup in hiera or in the environment.conf.
  $users           = lookup('unix_accounts', Hash[String[1], Data], 'hash', {})
  $ssh_public_keys = lookup('ssh_public_keys',
                            Hash[String[1], Hash[String[1], String[1], 2, 2]],
                            'hash', {})
  $fqdn_in_prompt  = false

  $supported_distribs = [ 'trusty', 'jessie' ]
  $default_stage      = 'basis';

  {
    unix_accounts::params::users           => $users,
    unix_accounts::params::ssh_public_keys => $ssh_public_keys,
    unix_accounts::params::fqdn_in_prompt  => $fqdn_in_prompt,

    unix_accounts::stage                   => $default_stage,
    unix_accounts::supported_distributions => $supported_distribs,
  }

}


