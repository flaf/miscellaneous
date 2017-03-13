class repository::moobot {

  include '::repository::moobot::params'

  [
   $url,
   $key_url,
   $fingerprint,
   $supported_distributions,
  ] = Class['::repository::moobot::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  repository::aptkey { 'moobot':
    id     => $fingerprint,
    source => $key_url,
  }

  repository::sourceslist { 'moobot':
    comment    => 'Moobot Repository.',
    location   => $url,
    release    => 'moobot',
    components => [ 'main' ],
    src        => false,
    require    => Repository::Aptkey['moobot'],
  }

}


