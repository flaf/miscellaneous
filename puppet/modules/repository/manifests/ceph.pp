class repository::ceph {

  include '::repository::ceph::params'

  [
   $url,
   $src,
   $codename,
   $pinning_version,
   $supported_distributions,
  ] = Class['::repository::ceph::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if $codename !~ Enum['infernalis', 'jewel'] {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the value of the parameter
      `repository::params::ceph_codename` is not valid (maybe undefined).
      You must define it explicitly and now valid values are: 'infernalis'
      or 'jewel'.
      |- END
  }

  ::homemade::fail_if_undef($pinning_version, 'pinning_version', $title)

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

  repository::aptkey { 'ceph':
    id => $key,
  }

  repository::sourceslist { 'ceph':
    comment    => 'Ceph Repository.',
    location   => "${cleaned_url}/debian-${codename}",
    release    => $::facts['lsbdistcodename'],
    components => [ 'main' ],
    src        => $src,
    require    => Repository::Aptkey['ceph'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    #
    # To see the patterns of all ceph package, you can run:
    #
    #   apt-cache search '.*' | grep ceph | awk '{print $1}' | sort | uniq
    #
    repository::pinning { 'ceph':
      explanation => 'To ensure the version of the ceph packages.',
      packages    => '/^(ceph|ceph-.*|libceph.*|librados.*|librbd[1-9]|librgw[1-9]|python-ceph.*|python-rados|python-rbd)$/',
      version     => $pinning_version,
      priority    => 990,
    }

  }

}


