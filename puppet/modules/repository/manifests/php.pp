class repository::php {

  include '::repository::php::params'

  [
   $url,
   $key_url,
   $apt_key_fingerprint,
   $supported_distributions,
  ] = Class['repository::php::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'php':
    id     => $apt_key_fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'php':
    comment    => 'Local PHP Repository.',
    location   => $url,
    release    => 'php',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['php'],
  }

}


