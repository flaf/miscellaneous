class repository::jrds {

  include '::repository::jrds::params'

  [
   $url,
   $key_url,
   $fingerprint,
   $supported_distributions,
  ] = Class['::repository::jrds::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'jrds':
    id     => $fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'jrds':
    comment  => 'Local JRDS Repository.',
    location => $url,
    release  => 'jrds',
    components => [ 'main' ],
    src        => false,
    require  => Repository::Aptkey['jrds'],
  }

}


