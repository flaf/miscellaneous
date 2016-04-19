class repository::ceph (
  String[1] $stage = 'repository',
) {

  include '::repository::ceph::params'

  $url             = $::repository::ceph::params::url
  $src             = $::repository::ceph::params::src
  $codename        = $::repository::ceph::params::codename
  $pinning_version = $::repository::ceph::params::pinning_version

  if $codename !~ Enum['infernalis', 'jewel'] {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the value of the parameter
      `repository::params::ceph_codename` is not valid (maybe undefined).
      You must define it explicitly and now valid values are: 'infernalis'
      or 'jewel'.
      |- END
  }

  if $pinning_version =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter `repository::params::ceph_pinning_version`
      is undefined. You must define it explicitly.
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


