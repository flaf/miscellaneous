function unix_accounts::data {

  {
    unix_accounts::params::users           => {},
    unix_accounts::params::ssh_public_keys => {},
    unix_accounts::params::fqdn_in_prompt  => false,

    unix_accounts::supported_distributions => [ 'trusty', 'jessie' ],
    unix_accounts::root::stage             => 'basis',

    # Merging policy.
    lookup_options => {
      unix_accounts::params::users           => { merge => 'hash', },
      unix_accounts::params::ssh_public_keys => { merge => 'hash', },
    },

  }

}


