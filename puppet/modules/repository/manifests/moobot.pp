class repository::moobot (
  String[1] $stage = 'repository',
) {

  include '::repository::moobot::params'

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


