function unix_accounts::data (
  Hash                  $options,
  Puppet::LookupContext $context,
) {

  {
    unix_accounts::params::users                   => {},
    unix_accounts::params::ssh_public_keys         => {},
    unix_accounts::params::rootstage               => 'main',
    unix_accounts::params::supported_distributions => [
                                                        'trusty',
                                                        'xenial',
                                                        'jessie',
                                                      ],

    # Merging policy.
    lookup_options => {
      unix_accounts::params::users           => { merge => 'deep', },
      unix_accounts::params::ssh_public_keys => { merge => 'deep', },
    },

  }

}


