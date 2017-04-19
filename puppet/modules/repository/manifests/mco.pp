class repository::mco {

  include '::repository::mco::params'

  [
   $url,
   $key_url,
   $apt_key_fingerprint,
   $supported_distributions,
  ] = Class['::repository::mco::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'mco':
    id     => $apt_key_fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'mco':
    comment    => 'Homemade MCollective Repository.',
    location   => $url,
    release    => 'mco',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['mco'],
  }

}


