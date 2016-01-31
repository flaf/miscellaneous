class repository::jrds (
  String[1]           $url,
  String[1]           $key_url,
  String[1]           $fingerprint,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

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


