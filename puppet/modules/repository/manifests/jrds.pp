class repository::jrds (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::jrds::params']) {
    include '::repository::jrds::params'
  }

  $url         = $::repository::jrds::params::url
  $key_url     = $::repository::jrds::params::key_url
  $fingerprint = $::repository::jrds::params::fingerprint

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


