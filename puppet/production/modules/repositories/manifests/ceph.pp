class repositories::ceph (
  $version = 'firefly',
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Module `${module_name}` is not supported or not yet tested on ${::lsbdistcodename}.")
    }
  }

  include '::apt'

  apt::source { 'ceph-repository':
    location    => "http://ceph.com/debian-${version}/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '17ED316D',
    include_src => false,
  }

}

