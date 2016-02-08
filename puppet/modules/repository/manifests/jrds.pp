class repository::jrds (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::params']) { include '::repository::params' }
  $url         = $::repository::params::jrds_url
  $key_url     = $::repository::params::jrds_key_url
  $fingerprint = $::repository::params::jrds_fingerprint

  apt::key { 'jrds':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'jrds':
    comment  => 'Local JRDS Repository.',
    location => $url,
    release  => 'jrds',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['jrds'],
  }

}


