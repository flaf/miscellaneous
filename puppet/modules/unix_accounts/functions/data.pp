function unix_accounts::data {

  {
    unix_accounts::params::users                   => {},
    unix_accounts::params::ssh_public_keys         => {},
    unix_accounts::params::rootstage               => 'main',
    unix_accounts::params::supported_distributions => [
                                                        'trusty',
                                                        'jessie',
                                                        'xenial',
                                                      ],

    # Merging policy.
    lookup_options => {
      unix_accounts::params::users           => { merge => 'deep', },
      unix_accounts::params::ssh_public_keys => { merge => 'deep', },
    },

  }

}


