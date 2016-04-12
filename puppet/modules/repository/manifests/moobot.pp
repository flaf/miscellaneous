class repository::moobot (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::moobot::params']) {
    include '::repository::moobot::params'
  }
  $url         = $::repository::moobot::params::url
  $key_url     = $::repository::moobot::params::key_url
  $fingerprint = $::repository::moobot::params::fingerprint

  apt::key { 'moobot':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'moobot':
    comment  => 'Moobot Repository.',
    location => $url,
    release  => 'moobot',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['moobot'],
  }

}


