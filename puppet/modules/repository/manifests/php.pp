class repository::php (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::params']) { include '::repository::params' }
  $url         = $::repository::params::php_url
  $key_url     = $::repository::params::php_key_url
  $fingerprint = $::repository::params::php_fingerprint

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


