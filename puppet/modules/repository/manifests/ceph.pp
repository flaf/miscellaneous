class repository::ceph (
  String[1]           $url,
  String[1]           $version,
  Boolean             $src,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Fingerprint of the APT key:
  #
  #   Ceph.com (release key) <security@ceph.com>
  #
  # To install this APT key:
  #
  #   url='https://git.ceph.com/release.asc'
  #   wget -q -O- "$url" | apt-key add -
  #
  $key         = '08B73419AC32B4E966C1A330E84AC2C0460F3994'
  $cleaned_url = $url.regsubst(/\/$/,'') # Remove the trailing slash.

  apt::source { 'ceph':
    comment  => 'Ceph Repository.',
    location => "${cleaned_url}/debian-${version}",
    release  => $::facts['lsbdistcodename'],
    repos    => 'main',
    key      => $key,
    include  => { 'src' => $src, 'deb' => true },
  }

}


