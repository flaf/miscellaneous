function locale::data {

  $supported_distributions = [
                               'trusty',
                               'xenial',
                               'jessie',
                             ];

  {
    locale::params::default_locale          => 'en_US.UTF-8',
    locale::params::supported_distributions => $supported_distributions,
  }

}


