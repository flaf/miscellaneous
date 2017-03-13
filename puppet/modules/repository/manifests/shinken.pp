class repository::shinken {

  include '::repository::shinken::params'

  [
   $url,
   $key_url,
   $fingerprint,
   $supported_distributions,
  ] = Class['::repository::shinken::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'shinken':
    id     => $fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'shinken':
    comment    => 'Homemade Shinken Repository.',
    location   => $url,
    release    => 'shinken',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['shinken'],
  }

}


