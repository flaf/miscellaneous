class repository::postgresql {

  include '::repository::postgresql::params'

  [
   $url,
   $src,
   $supported_distributions,
  ] = Class['::repository::postgresql::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $codename = $::facts['lsbdistcodename']
  $key      = 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'

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


