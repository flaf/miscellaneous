class repository::ceph (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url             = $::repository::params::ceph_url
  $src             = $::repository::params::ceph_src
  $codename        = $::repository::params::ceph_codename
  $pinning_version = $::repository::params::ceph_pinning_version

  if $codename == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `repository::params::ceph_codename` is not valid.
      You must define it explicitly.
      |- END
  }

  if $pinning_version == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `repository::params::ceph_pinning_version` is not valid.
      You must define it explicitly.
      |- END
  }

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

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'ceph':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { 'ceph':
    comment  => 'Ceph Repository.',
    location => "${cleaned_url}/debian-${codename}",
    release  => $::facts['lsbdistcodename'],
    repos    => 'main',
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['ceph'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    #
    # To see the patterns of all ceph package, you can run:
    #
    #   apt-cache search '.*' | grep ceph | awk '{print $1}' | sort | uniq
    #
    apt::pin { 'ceph':
      explanation => 'To ensure the version of the ceph packages.',
      packages    => '/^(ceph|ceph-.*|libceph.*|python-ceph.*)$/',
      version     => $pinning_version,
      priority    => 990,
    }

  }

}


