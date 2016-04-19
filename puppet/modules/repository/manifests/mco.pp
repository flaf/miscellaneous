class repository::mco (
  String[1] $stage = 'repository',
) {

  include '::repository::mco::params'

  $url         = $::repository::mco::params::url
  $key_url     = $::repository::mco::params::key_url
  $fingerprint = $::repository::mco::params::fingerprint

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


