class repository::moobot (
  String[1]           $url,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  apt::key { 'moobot':
    source => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  }

  apt::source { 'moobot':
    comment  => 'Moobot Repository.',
    location => $url,
    release  => 'moobot',
    repos    => 'main',
    include  => { 'src' => $src, 'deb' => true },
  }

}


