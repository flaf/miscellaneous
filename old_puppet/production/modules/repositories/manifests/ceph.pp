# Puppet class to manage the "Ceph release" APT repository.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and Puppetlabs-apt.
#
# == Parameters
#
# *version:*
# The version of Ceph to use.
# Currently, it can be only set to 'hammer' which is
# the default value.
#
# == Sample Usages
#
#  include '::repositories::ceph'
#
# or:
#
#  class { '::repositories::ceph':
#   version => 'hammer',
#  }
#
class repositories::ceph (
  $version = 'hammer',
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_string($version)
  unless member(['hammer'], $version) {
    fail("Class ${title}, version `#{$version}` are not supported.")
  }

  # Fingerprint of the APT key:
  #
  #   Ceph Release Key <sage@newdream.net>.
  #
  # To install this APT key:
  #
  #   url='https://git.ceph.com/release.asc'
  #   wget -q -O- "$url" | apt-key add -
  #
  $key = '08B73419AC32B4E966C1A330E84AC2C0460F3994'

  apt::source { 'ceph':
    comment     => 'The Ceph repository.',
    location    => "http://ceph.com/debian-${version}/",
    # For testing...
    #location    => "http://ceph.com/debian-testing/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => $key,
    include_src => false,
  }

}


