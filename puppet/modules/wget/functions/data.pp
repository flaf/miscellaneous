function wget::data {

  $supported_distribution = [
                              'trusty',
                              'xenial',
                              'jessie',
                            ];

  {
    wget::params::http_proxy              => 'unmanaged',
    wget::params::https_proxy             => 'unmanaged',
    wget::params::supported_distributions => $supported_distribution,
  }

}


