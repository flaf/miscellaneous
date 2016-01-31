class repository::raid (
  String[1]           $url,
  String[1]           $key_url,
  String[1]           $fingerprint,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

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


