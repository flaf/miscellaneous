# TODO: make a documentation header and add
#       a is_string() test for the parameter
#       and a empty() test (functions of stdlib).

class repositories::ceph (
  $version = 'firefly',
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  include '::apt'

  apt::source { 'ceph':
    location    => "http://ceph.com/debian-${version}/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '17ED316D',
    include_src => false,
  }

}

