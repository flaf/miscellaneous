class repository::mco (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::mco::params']) {
    include '::repository::mco::params'
  }

  $url         = $::repository::mco::params::url
  $key_url     = $::repository::mco::params::key_url
  $fingerprint = $::repository::mco::params::fingerprint

  apt::key { 'mco':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'mco':
    comment  => 'Homemade MCollective Repository.',
    location => $url,
    release  => 'mco',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['mco'],
  }

}


