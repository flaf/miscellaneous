class repository::shinken (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::shinken::params']) {
    include '::repository::shinken::params'
  }

  $url         = $::repository::shinken::params::url
  $key_url     = $::repository::shinken::params::key_url
  $fingerprint = $::repository::shinken::params::fingerprint

  apt::key { 'shinken':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'shinken':
    comment  => 'Homemade Shinken Repository.',
    location => $url,
    release  => 'shinken',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['shinken'],
  }

}


