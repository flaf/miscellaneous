class repository::raid (
  String[1] $stage = 'repository',
) {

  include '::repository::raid::params'

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


