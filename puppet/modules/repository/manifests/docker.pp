class repository::docker (
  String[1]           $url,
  Boolean             $src,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $key      = '58118E89F3A912897C070ADBF76221572C52609D'
  $codename = $::facts['lsbdistcodename']
  $osid     = $::facts['lsbdistid'].downcase # typically "debian" or "ubuntu"
  $release  = "${osid}-${codename}"

  apt::source { 'docker':
    comment  => 'Docker Repository.',
    location => $url,
    release  => $release,
    repos    => 'main',
    key      => $key,
    include  => { 'src' => $src, 'deb' => true },
  }

}


