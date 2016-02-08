class repository::raid (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url         = $::repository::params::raid_url
  $key_url     = $::repository::params::raid_key_url
  $fingerprint = $::repository::params::raid_fingerprint

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


