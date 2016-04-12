class repository::php (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::php::params']) {
    include '::repository::php::params'
  }

  $url         = $::repository::php::params::url
  $key_url     = $::repository::php::params::key_url
  $fingerprint = $::repository::php::params::fingerprint

  apt::key { 'php':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'php':
    comment  => 'Local PHP Repository.',
    location => $url,
    release  => 'php',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['php'],
  }

}


