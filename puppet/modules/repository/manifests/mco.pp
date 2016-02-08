class repository::mco (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url         = $::repository::params::mco_url
  $key_url     = $::repository::params::mco_key_url
  $fingerprint = $::repository::params::mco_fingerprint

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


