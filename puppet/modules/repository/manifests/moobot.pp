class repository::moobot (
  String[1]           $url,
  String[1]           $key_url,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $fingerprint = '741FA112F3B2D515A88593F83DE39DE978BB3659'

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


