class repository::moobot (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url         = $::repository::params::moobot_url
  $key_url     = $::repository::params::moobot_key_url
  $fingerprint = $::repository::params::moobot_fingerprint

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


