function keyboard::data {

  $supported_distributions = [
                              'trusty',
                              'xenial',
                              'jessie',
                             ];

  {
    keyboard::params::xkbmodel                => 'pc105',
    keyboard::params::xkblayout               => 'fr',
    keyboard::params::xkbvariant              => 'latin9',
    keyboard::params::xkboptions              => '',
    keyboard::params::backspace               => 'guess',
    keyboard::params::supported_distributions => $supported_distributions,
  }

}


