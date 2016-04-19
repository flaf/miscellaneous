class repository::php (
  String[1] $stage = 'repository',
) {

  include '::repository::php::params'

  $url         = $::repository::php::params::url
  $key_url     = $::repository::php::params::key_url
  $fingerprint = $::repository::php::params::fingerprint

  apt::key { 'php':
    id     => $fingerprint,
    source => $key_url,
  }

  apt::source { 'php':
    comment  => 'Local PHP Repository.',
    location => $url,
    release  => 'php',
    repos    => 'main',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['php'],
  }

}


