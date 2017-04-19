class repository::raid {

  include '::repository::raid::params'

  [
   $url,
   $key_url,
   $apt_key_fingerprint,
   $supported_distributions,
  ] = Class['::repository::raid::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'raid':
    id     => $apt_key_fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'raid':
    comment    => 'Homemade RAID Repository.',
    location   => $url,
    release    => 'raid',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['raid'],
  }

}


