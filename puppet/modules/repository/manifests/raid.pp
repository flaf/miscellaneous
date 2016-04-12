class repository::raid (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::raid::params']) {
    include '::repository::raid::params'
  }

  $url         = $::repository::raid::params::url
  $key_url     = $::repository::raid::params::key_url
  $fingerprint = $::repository::raid::params::fingerprint

  apt::key { 'raid':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'raid':
    comment  => 'Homemade RAID Repository.',
    location => $url,
    release  => 'raid',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['raid'],
  }

}


