function rsyncd::data {

  {
    rsyncd::params::modules                 => {},
    rsyncd::params::users                   => {},
    rsyncd::params::supported_distributions => ['trusty', 'jessie'],

    # Merging policy.
    lookup_options => {
       rsyncd::params::modules => { merge => 'deep', },
       rsyncd::params::users   => { merge => 'deep', },
    },
  }

}


