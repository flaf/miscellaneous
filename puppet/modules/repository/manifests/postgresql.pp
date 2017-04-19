class repository::postgresql {

  include '::repository::postgresql::params'

  [
   $url,
   $src,
   $apt_key_fingerprint,
   $supported_distributions,
  ] = Class['::repository::postgresql::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $codename = $::facts['lsbdistcodename']
  $key      = $apt_key_fingerprint

  repository::aptkey { 'postgresql':
    id => $key,
  }

  repository::sourceslist { 'postgresql':
    comment    => 'PostgreSQL Repository.',
    location   => "${url}",
    release    => "${codename}-pgdg",
    components => [ 'main' ],
    src        => $src,
    require    => Repository::Aptkey['postgresql'],
  }

}


